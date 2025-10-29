#!/bin/bash

# 测试 /api/v1/ai/travel-plan/stream 接口
# 支持流式响应 (Server-Sent Events)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
BASE_URL="http://localhost:5000"
ENDPOINT="/api/v1/ai/travel-plan/stream"
TEST_DATA_FILE="test_data/travel_plan_stream_requests.json"

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo -e "${RED}错误: 需要安装 jq 来解析 JSON${NC}"
    echo "macOS 安装: brew install jq"
    exit 1
fi

# 显示使用说明
show_usage() {
    cat << EOF
使用方法:
  ./test-travel-plan-stream.sh [选项] [测试用例ID]

选项:
  -h, --help          显示此帮助信息
  -l, --list          列出所有测试用例
  -a, --all           运行所有测试用例
  -u, --url URL       指定基础 URL (默认: $BASE_URL)
    -v, --verbose       显示详细输出
    -r, --raw           输出原始 SSE 数据 (data: ...)

示例:
  ./test-travel-plan-stream.sh                    # 交互式选择测试用例
  ./test-travel-plan-stream.sh test-001-basic     # 运行指定测试用例
  ./test-travel-plan-stream.sh -a                 # 运行所有测试用例
  ./test-travel-plan-stream.sh -l                 # 列出所有测试用例
EOF
}

# 列出所有测试用例
list_test_cases() {
    echo -e "${BLUE}可用的测试用例:${NC}\n"
    jq -r '.test_cases[] | "\(.id)\t\(.name)\n  描述: \(.description)\n"' "$TEST_DATA_FILE"
}

# 运行单个测试用例
run_test_case() {
    local test_id=$1
    local verbose=$2
    local raw_mode=$3

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local test_case=$(jq ".test_cases[] | select(.id == \"$test_id\")" "$TEST_DATA_FILE")

    if [ -z "$test_case" ]; then
        echo -e "${RED}错误: 找不到测试用例 $test_id${NC}"
        return 1
    fi

    local name=$(echo "$test_case" | jq -r '.name')
    local description=$(echo "$test_case" | jq -r '.description')
    local request_body=$(echo "$test_case" | jq -c '.request')
    local should_succeed=$(echo "$test_case" | jq -r '.expected.should_succeed')

    echo -e "${YELLOW}测试用例:${NC} $name"
    echo -e "${YELLOW}ID:${NC} $test_id"
    echo -e "${YELLOW}描述:${NC} $description"
    echo ""

    if [ "$verbose" = "true" ]; then
        echo -e "${YELLOW}请求参数:${NC}"
        echo "$request_body" | jq .
        echo ""
    fi

    echo -e "${BLUE}发送请求到:${NC} $BASE_URL$ENDPOINT"
    echo -e "${BLUE}开始接收流式响应...${NC}\n"

    local start_time=$(date +%s)
    local response_file=$(mktemp)
    local event_count=0
    local last_event_type=""
    local fifo=$(mktemp -u -t travel_stream_fifo.XXXXXX)
    local curl_log=$(mktemp)

    mkfifo "$fifo"

    curl -N -X POST "$BASE_URL$ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Accept: text/event-stream" \
        -d "$request_body" \
        > "$fifo" 2> "$curl_log" &

    local curl_pid=$!

    while IFS= read -r line; do
        if [[ $line == data:* ]]; then
            local json_data="${line#data: }"
            local event_type=$(echo "$json_data" | jq -r '.type' 2>/dev/null)

            if [ "$event_type" != "null" ] && [ -n "$event_type" ]; then
                event_count=$((event_count + 1))
                last_event_type="$event_type"

                case "$event_type" in
                    "start")
                        local message=$(echo "$json_data" | jq -r '.payload.message')
                        echo -e "${GREEN}▶ 开始:${NC} $message"
                        ;;
                    "analyzing")
                        local message=$(echo "$json_data" | jq -r '.payload.message')
                        local progress=$(echo "$json_data" | jq -r '.payload.progress')
                        echo -e "${BLUE}⚙ 分析中:${NC} $message (进度: ${progress}%)"
                        ;;
                    "generating")
                        local message=$(echo "$json_data" | jq -r '.payload.message')
                        local progress=$(echo "$json_data" | jq -r '.payload.progress')
                        echo -e "${YELLOW}⚡ 生成中:${NC} $message (进度: ${progress}%)"
                        ;;
                    "success")
                        echo -e "${GREEN}✓ 完成:${NC} 旅行计划生成成功"
                        echo "$json_data" > "$response_file"

                        echo ""
                        echo -e "${YELLOW}响应数据:${NC}"
                        if [ "$verbose" = "true" ]; then
                            echo "$json_data" | jq '.payload.data | {id: .Id, cityName: .CityName, duration: .Duration, dailyItineraries: (.DailyItineraries | length), attractions: (.Attractions | length), restaurants: (.Restaurants | length)}'
                        fi
                        echo "$json_data" | jq '.payload.data'
                        ;;
                    "error")
                        local error_msg=$(echo "$json_data" | jq -r '.payload.error // .payload.message // "未知错误"')
                        echo -e "${RED}✗ 错误:${NC} $error_msg"
                        echo "$json_data" > "$response_file"
                        ;;
                    *)
                        if [ "$verbose" = "true" ]; then
                            echo -e "${BLUE}📨 事件:${NC} $event_type"
                            echo "$json_data" | jq .
                        fi
                        ;;
                esac

                if [ "$raw_mode" = "true" ]; then
                    echo "data: $json_data"
                fi
            fi
        fi
    done < "$fifo"

    wait $curl_pid
    local curl_exit_code=$?

    rm -f "$fifo"

    if [ "$verbose" = "true" ] && [ -s "$curl_log" ]; then
        echo ""
        echo -e "${YELLOW}curl 调试输出:${NC}"
        cat "$curl_log"
    fi

    rm -f "$curl_log"

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ $curl_exit_code -eq 18 ] && [ "$last_event_type" = "success" ]; then
        [ "$verbose" = "true" ] && echo -e "${YELLOW}⚠️ 提示:${NC} curl 退出码 18 (流关闭) 已视为成功"
        curl_exit_code=0
    fi

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}统计信息:${NC}"
    echo "  • 总事件数: $event_count"
    echo "  • 最后事件: $last_event_type"
    echo "  • 耗时: ${duration}s"
    echo "  • curl 退出码: $curl_exit_code"

    local result_status=1

    if [ $curl_exit_code -ne 0 ]; then
        echo -e "${RED}  • 结果: ✗ curl 返回错误 (退出码 $curl_exit_code)${NC}"
    elif [ -f "$response_file" ] && [ -s "$response_file" ]; then
        local actual_type=$(jq -r '.type' "$response_file" 2>/dev/null)

        if [ "$should_succeed" = "true" ]; then
            if [ "$actual_type" = "success" ]; then
                echo -e "${GREEN}  • 结果: ✓ 测试通过${NC}"
                result_status=0
            else
                echo -e "${RED}  • 结果: ✗ 预期成功但失败${NC}"
            fi
        else
            if [ "$actual_type" = "error" ]; then
                echo -e "${GREEN}  • 结果: ✓ 测试通过 (预期失败)${NC}"
                result_status=0
            else
                echo -e "${RED}  • 结果: ✗ 预期失败但成功${NC}"
            fi
        fi
    else
        echo -e "${RED}  • 结果: ✗ 未收到响应${NC}"
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    rm -f "$response_file"

    return $result_status
}

# 运行所有测试用例
run_all_tests() {
    local verbose=$1
    local raw_mode=$2
    local test_ids=$(jq -r '.test_cases[].id' "$TEST_DATA_FILE")
    local total=$(echo "$test_ids" | wc -l | xargs)
    local current=0

    echo -e "${BLUE}运行所有测试用例 (共 $total 个)${NC}\n"

    for test_id in $test_ids; do
        current=$((current + 1))
        echo -e "${YELLOW}[$current/$total]${NC}"
    run_test_case "$test_id" "$verbose" "$raw_mode"

        if [ $current -lt $total ]; then
            echo -e "${BLUE}按 Enter 继续下一个测试, Ctrl+C 退出...${NC}"
            read -r
        fi
    done

    echo -e "${GREEN}所有测试完成!${NC}"
}

# 交互式选择
interactive_select() {
    local verbose=$1
    local raw_mode=$2

    echo -e "${BLUE}请选择要运行的测试用例:${NC}\n"

    local test_ids=($(jq -r '.test_cases[].id' "$TEST_DATA_FILE"))
    local test_names=($(jq -r '.test_cases[].name' "$TEST_DATA_FILE"))

    for i in "${!test_ids[@]}"; do
        echo "$((i + 1)). ${test_names[$i]} (${test_ids[$i]})"
    done

    echo ""
    read -p "输入序号 (1-${#test_ids[@]}): " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#test_ids[@]}" ]; then
        local selected_id="${test_ids[$((choice - 1))]}"
    run_test_case "$selected_id" "$verbose" "$raw_mode"
    else
        echo -e "${RED}无效的选择${NC}"
        exit 1
    fi
}

# 主逻辑
VERBOSE=false
RUN_ALL=false
LIST_ONLY=false
RAW_MODE=false
TEST_ID=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -l|--list)
            LIST_ONLY=true
            shift
            ;;
        -a|--all)
            RUN_ALL=true
            shift
            ;;
        -u|--url)
            BASE_URL="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -r|--raw)
            RAW_MODE=true
            shift
            ;;
        *)
            TEST_ID="$1"
            shift
            ;;
    esac
done

# 检查测试数据文件
if [ ! -f "$TEST_DATA_FILE" ]; then
    echo -e "${RED}错误: 找不到测试数据文件 $TEST_DATA_FILE${NC}"
    exit 1
fi

# 执行操作
if [ "$LIST_ONLY" = true ]; then
    list_test_cases
elif [ "$RUN_ALL" = true ]; then
    run_all_tests "$VERBOSE" "$RAW_MODE"
elif [ -n "$TEST_ID" ]; then
    run_test_case "$TEST_ID" "$VERBOSE" "$RAW_MODE"
else
    interactive_select "$VERBOSE" "$RAW_MODE"
fi
