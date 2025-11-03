-- 用户收藏城市表
CREATE TABLE IF NOT EXISTS user_favorite_cities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    city_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 确保同一用户不会重复收藏同一城市
    UNIQUE(user_id, city_id)
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_user_favorite_cities_user_id ON user_favorite_cities(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorite_cities_city_id ON user_favorite_cities(city_id);
CREATE INDEX IF NOT EXISTS idx_user_favorite_cities_created_at ON user_favorite_cities(created_at DESC);

-- 自动更新 updated_at 字段的触发器
CREATE OR REPLACE FUNCTION update_user_favorite_cities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_favorite_cities_updated_at
    BEFORE UPDATE ON user_favorite_cities
    FOR EACH ROW
    EXECUTE FUNCTION update_user_favorite_cities_updated_at();

-- 启用 RLS (Row Level Security)
ALTER TABLE user_favorite_cities ENABLE ROW LEVEL SECURITY;

-- RLS 策略：用户只能查看自己的收藏
CREATE POLICY "Users can view their own favorite cities"
    ON user_favorite_cities
    FOR SELECT
    USING (auth.uid() = user_id);

-- RLS 策略：用户只能添加自己的收藏
CREATE POLICY "Users can add their own favorite cities"
    ON user_favorite_cities
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- RLS 策略：用户只能删除自己的收藏
CREATE POLICY "Users can delete their own favorite cities"
    ON user_favorite_cities
    FOR DELETE
    USING (auth.uid() = user_id);

-- RLS 策略：用户只能更新自己的收藏
CREATE POLICY "Users can update their own favorite cities"
    ON user_favorite_cities
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 添加注释
COMMENT ON TABLE user_favorite_cities IS '用户收藏的城市列表';
COMMENT ON COLUMN user_favorite_cities.id IS '收藏记录ID';
COMMENT ON COLUMN user_favorite_cities.user_id IS '用户ID';
COMMENT ON COLUMN user_favorite_cities.city_id IS '城市ID';
COMMENT ON COLUMN user_favorite_cities.created_at IS '收藏时间';
COMMENT ON COLUMN user_favorite_cities.updated_at IS '最后更新时间';
