import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:go_nomads_app/services/http_service.dart';

class AppConfigSection {
  final String title;
  final String content;

  const AppConfigSection({
    required this.title,
    required this.content,
  });
}

class LegalConsentVersions {
  final String? privacyPolicyVersion;
  final String? termsOfServiceVersion;

  const LegalConsentVersions({
    this.privacyPolicyVersion,
    this.termsOfServiceVersion,
  });
}

class FirstLaunchPrivacyDialogCopy {
  final String? title;
  final String? intro;
  final String? privacyCheckboxPrefix;
  final String? termsCheckboxPrefix;
  final String? declineTipPrefix;
  final String? declineTipLinkSeparator;
  final String? declineTipLinkFinalConnector;
  final String? declineTipSuffix;
  final String? sdkLinkLabel;
  final String? agreeButtonLabel;
  final String? rejectButtonLabel;
  final String? summaryFallbackTitle;
  final String? summaryFallbackContent;
  final String? uncheckedToastTitle;
  final String? uncheckedToastMessage;
  final String? declineConfirmTitle;
  final String? declineConfirmMessage;
  final String? declineConfirmCancelLabel;
  final String? declineConfirmExitLabel;

  const FirstLaunchPrivacyDialogCopy({
    this.title,
    this.intro,
    this.privacyCheckboxPrefix,
    this.termsCheckboxPrefix,
    this.declineTipPrefix,
    this.declineTipLinkSeparator,
    this.declineTipLinkFinalConnector,
    this.declineTipSuffix,
    this.sdkLinkLabel,
    this.agreeButtonLabel,
    this.rejectButtonLabel,
    this.summaryFallbackTitle,
    this.summaryFallbackContent,
    this.uncheckedToastTitle,
    this.uncheckedToastMessage,
    this.declineConfirmTitle,
    this.declineConfirmMessage,
    this.declineConfirmCancelLabel,
    this.declineConfirmExitLabel,
  });
}

class ForgotPasswordCopy {
  final String? accountStepTitle;
  final String? accountStepDescription;
  final String? accountInputLabel;
  final String? accountSendCodeButton;
  final String? verifyStepTitle;
  final String? verifyStepDescriptionTemplate;
  final String? verifyCodeLabel;
  final String? verifyResendCountdownTemplate;
  final String? verifyResendButton;
  final String? verifyNextButton;
  final String? resetStepTitle;
  final String? resetStepDescription;
  final String? resetNewPasswordLabel;
  final String? resetConfirmPasswordLabel;
  final String? resetSubmitButton;
  final String? toastAccountRequired;
  final String? toastCodeSentEmail;
  final String? toastCodeSentPhone;
  final String? toastSendFailedFallback;
  final String? toastCodeRequired;
  final String? toastCodeIncomplete;
  final String? toastNewPasswordRequired;
  final String? toastPasswordMinLength;
  final String? toastConfirmPasswordRequired;
  final String? toastPasswordMismatch;
  final String? toastResetSuccess;
  final String? toastResetFailedFallback;

  const ForgotPasswordCopy({
    this.accountStepTitle,
    this.accountStepDescription,
    this.accountInputLabel,
    this.accountSendCodeButton,
    this.verifyStepTitle,
    this.verifyStepDescriptionTemplate,
    this.verifyCodeLabel,
    this.verifyResendCountdownTemplate,
    this.verifyResendButton,
    this.verifyNextButton,
    this.resetStepTitle,
    this.resetStepDescription,
    this.resetNewPasswordLabel,
    this.resetConfirmPasswordLabel,
    this.resetSubmitButton,
    this.toastAccountRequired,
    this.toastCodeSentEmail,
    this.toastCodeSentPhone,
    this.toastSendFailedFallback,
    this.toastCodeRequired,
    this.toastCodeIncomplete,
    this.toastNewPasswordRequired,
    this.toastPasswordMinLength,
    this.toastConfirmPasswordRequired,
    this.toastPasswordMismatch,
    this.toastResetSuccess,
    this.toastResetFailedFallback,
  });
}

class PreAuthLegalCopy {
  final String? loginTermsPrefix;
  final String? loginTermsConnector;
  final String? loginTermsSuffix;
  final String? registerTermsPrefix;
  final String? registerTermsConnector;
  final String? registerTermsCommunityPrefix;
  final String? registerTermsSuffix;
  final String? legalLinksPrefix;
  final String? legalLinksConnector;
  final String? legalLinksSuffix;

  const PreAuthLegalCopy({
    this.loginTermsPrefix,
    this.loginTermsConnector,
    this.loginTermsSuffix,
    this.registerTermsPrefix,
    this.registerTermsConnector,
    this.registerTermsCommunityPrefix,
    this.registerTermsSuffix,
    this.legalLinksPrefix,
    this.legalLinksConnector,
    this.legalLinksSuffix,
  });
}

class PublicBrandingCopy {
  final String? loadingTitle;
  final String? loadingTagline;
  final String? footerCopyright;
  final String? footerIcpRecord;

  const PublicBrandingCopy({
    this.loadingTitle,
    this.loadingTagline,
    this.footerCopyright,
    this.footerIcpRecord,
  });
}

class PreAuthMarketingCopy {
  final String? loginHeaderTitle;
  final String? loginHeaderSubtitle;
  final String? loginCommunityTitle;
  final String? loginCommunitySubtitle;
  final String? loginCommunityBadgeMeetups;
  final String? loginCommunityBadgeMessages;
  final String? loginCommunityBadgeCities;
  final String? loginRegisterLinkPrefix;
  final String? registerHeaderTitle;
  final String? registerHeaderSubtitle;
  final String? registerLoginLinkPrefix;
  final String? registerHighlightsTitle;
  final String? registerHighlightsMeetupsTitle;
  final String? registerHighlightsMeetupsSubtitle;
  final String? registerHighlightsPeopleTitle;
  final String? registerHighlightsPeopleSubtitle;
  final String? registerHighlightsDestinationsTitle;
  final String? registerHighlightsDestinationsSubtitle;
  final String? registerHighlightsChatTitle;
  final String? registerHighlightsChatSubtitle;
  final String? registerHighlightsTravelsTitle;
  final String? registerHighlightsTravelsSubtitle;

  const PreAuthMarketingCopy({
    this.loginHeaderTitle,
    this.loginHeaderSubtitle,
    this.loginCommunityTitle,
    this.loginCommunitySubtitle,
    this.loginCommunityBadgeMeetups,
    this.loginCommunityBadgeMessages,
    this.loginCommunityBadgeCities,
    this.loginRegisterLinkPrefix,
    this.registerHeaderTitle,
    this.registerHeaderSubtitle,
    this.registerLoginLinkPrefix,
    this.registerHighlightsTitle,
    this.registerHighlightsMeetupsTitle,
    this.registerHighlightsMeetupsSubtitle,
    this.registerHighlightsPeopleTitle,
    this.registerHighlightsPeopleSubtitle,
    this.registerHighlightsDestinationsTitle,
    this.registerHighlightsDestinationsSubtitle,
    this.registerHighlightsChatTitle,
    this.registerHighlightsChatSubtitle,
    this.registerHighlightsTravelsTitle,
    this.registerHighlightsTravelsSubtitle,
  });
}

class LoginFormCopy {
  final String? emailTabLabel;
  final String? phoneTabLabel;
  final String? emailLabel;
  final String? emailHint;
  final String? passwordLabel;
  final String? passwordHint;
  final String? rememberMe;
  final String? forgotPassword;
  final String? emailSubmitButton;
  final String? phoneLabel;
  final String? phoneHint;
  final String? smsCodeLabel;
  final String? smsCodeHint;
  final String? smsCodeSendButton;
  final String? smsCodeCountdownTemplate;
  final String? phoneSubmitButton;
  final String? emailRequiredError;
  final String? emailInvalidError;
  final String? passwordRequiredError;
  final String? phoneRequiredError;
  final String? phoneInvalidError;
  final String? smsCodeRequiredError;

  const LoginFormCopy({
    this.emailTabLabel,
    this.phoneTabLabel,
    this.emailLabel,
    this.emailHint,
    this.passwordLabel,
    this.passwordHint,
    this.rememberMe,
    this.forgotPassword,
    this.emailSubmitButton,
    this.phoneLabel,
    this.phoneHint,
    this.smsCodeLabel,
    this.smsCodeHint,
    this.smsCodeSendButton,
    this.smsCodeCountdownTemplate,
    this.phoneSubmitButton,
    this.emailRequiredError,
    this.emailInvalidError,
    this.passwordRequiredError,
    this.phoneRequiredError,
    this.phoneInvalidError,
    this.smsCodeRequiredError,
  });
}

class LoginFeedbackCopy {
  final String? termsRequiredTitle;
  final String? termsRequiredMessage;
  final String? phoneRequiredMessage;
  final String? phoneInvalidMessage;
  final String? smsCodeSentMessage;
  final String? sendFailedMessage;
  final String? sendSmsFailedMessage;
  final String? welcomeBackMessage;
  final String? loginSuccessTitle;
  final String? invalidEmailOrPasswordMessage;
  final String? loginFailedTitle;
  final String? unknownErrorRetryMessage;
  final String? loginFailedRetryMessage;
  final String? smsCodeInvalidOrExpiredMessage;
  final String? socialLoadingTitleTemplate;
  final String? pleaseWaitMessage;
  final String? socialFailedTemplate;

  const LoginFeedbackCopy({
    this.termsRequiredTitle,
    this.termsRequiredMessage,
    this.phoneRequiredMessage,
    this.phoneInvalidMessage,
    this.smsCodeSentMessage,
    this.sendFailedMessage,
    this.sendSmsFailedMessage,
    this.welcomeBackMessage,
    this.loginSuccessTitle,
    this.invalidEmailOrPasswordMessage,
    this.loginFailedTitle,
    this.unknownErrorRetryMessage,
    this.loginFailedRetryMessage,
    this.smsCodeInvalidOrExpiredMessage,
    this.socialLoadingTitleTemplate,
    this.pleaseWaitMessage,
    this.socialFailedTemplate,
  });
}

class LoginSocialCopy {
  final String? dividerLabel;
  final String? wechatLabel;
  final String? qqLabel;
  final String? appleLabel;
  final String? googleLabel;
  final String? twitterLabel;
  final String? facebookLabel;
  final String? facebookUnavailableTitle;
  final String? facebookUnavailableMessage;

  const LoginSocialCopy({
    this.dividerLabel,
    this.wechatLabel,
    this.qqLabel,
    this.appleLabel,
    this.googleLabel,
    this.twitterLabel,
    this.facebookLabel,
    this.facebookUnavailableTitle,
    this.facebookUnavailableMessage,
  });
}

class RegisterFormCopy {
  final String? usernameLabel;
  final String? usernameHint;
  final String? emailLabel;
  final String? emailHint;
  final String? verificationCodeLabel;
  final String? verificationCodeHint;
  final String? verificationCodeSendButton;
  final String? verificationCodeCountdownTemplate;
  final String? verificationCodeResendButton;
  final String? passwordLabel;
  final String? passwordHint;
  final String? confirmPasswordLabel;
  final String? confirmPasswordHint;
  final String? submitButton;
  final String? termsRequiredTitle;
  final String? termsRequiredMessage;
  final String? welcomeToastMessage;
  final String? successTitle;
  final String? usernameRequiredError;
  final String? usernameMinLengthError;
  final String? emailRequiredError;
  final String? emailInvalidError;
  final String? verificationCodeRequiredError;
  final String? verificationCodeLengthError;
  final String? passwordRequiredError;
  final String? passwordMinLengthError;
  final String? confirmPasswordRequiredError;
  final String? passwordsNotMatchError;

  const RegisterFormCopy({
    this.usernameLabel,
    this.usernameHint,
    this.emailLabel,
    this.emailHint,
    this.verificationCodeLabel,
    this.verificationCodeHint,
    this.verificationCodeSendButton,
    this.verificationCodeCountdownTemplate,
    this.verificationCodeResendButton,
    this.passwordLabel,
    this.passwordHint,
    this.confirmPasswordLabel,
    this.confirmPasswordHint,
    this.submitButton,
    this.termsRequiredTitle,
    this.termsRequiredMessage,
    this.welcomeToastMessage,
    this.successTitle,
    this.usernameRequiredError,
    this.usernameMinLengthError,
    this.emailRequiredError,
    this.emailInvalidError,
    this.verificationCodeRequiredError,
    this.verificationCodeLengthError,
    this.passwordRequiredError,
    this.passwordMinLengthError,
    this.confirmPasswordRequiredError,
    this.passwordsNotMatchError,
  });
}

class RegisterFeedbackCopy {
  final String? codeSentToEmailMessage;
  final String? sendFailedMessage;
  final String? sendCodeFailedRetryMessage;
  final String? registerFailedCheckInputMessage;
  final String? registerFailedTitle;
  final String? registerFailedProcessErrorMessage;

  const RegisterFeedbackCopy({
    this.codeSentToEmailMessage,
    this.sendFailedMessage,
    this.sendCodeFailedRetryMessage,
    this.registerFailedCheckInputMessage,
    this.registerFailedTitle,
    this.registerFailedProcessErrorMessage,
  });
}

class LoginEntryCopyBundle {
  final PreAuthMarketingCopy marketing;
  final LoginFormCopy form;
  final LoginFeedbackCopy feedback;
  final LoginSocialCopy social;

  const LoginEntryCopyBundle({
    required this.marketing,
    required this.form,
    required this.feedback,
    required this.social,
  });
}

class RegisterEntryCopyBundle {
  final PreAuthMarketingCopy marketing;
  final RegisterFormCopy form;
  final RegisterFeedbackCopy feedback;

  const RegisterEntryCopyBundle({
    required this.marketing,
    required this.form,
    required this.feedback,
  });
}

class PermissionPurposeCopy {
  final String? title;
  final String? description;
  final List<String> purposes;
  final String? note;
  final String? confirmText;

  const PermissionPurposeCopy({
    this.title,
    this.description,
    this.purposes = const [],
    this.note,
    this.confirmText,
  });
}

class LocationPermissionUiCopy {
  final String? dialogTitle;
  final String? dialogDescription;
  final String? dialogCancelButton;
  final String? dialogConfirmButton;
  final String? statusLoading;
  final String? statusDisabled;
  final String? statusEnableAction;

  const LocationPermissionUiCopy({
    this.dialogTitle,
    this.dialogDescription,
    this.dialogCancelButton,
    this.dialogConfirmButton,
    this.statusLoading,
    this.statusDisabled,
    this.statusEnableAction,
  });
}

class _AppSystemSetting {
  final String value;

  const _AppSystemSetting({required this.value});

  factory _AppSystemSetting.fromJson(Map<String, dynamic> json) {
    return _AppSystemSetting(
      value: (json['value'] ?? json['Value'] ?? '').toString(),
    );
  }
}

class _AppConfigPayload {
  final Map<String, String> staticTexts;
  final Map<String, Map<String, _AppSystemSetting>> systemSettings;

  const _AppConfigPayload({
    required this.staticTexts,
    required this.systemSettings,
  });

  factory _AppConfigPayload.fromJson(Map<String, dynamic> json) {
    final rawStaticTexts = json['staticTexts'] ?? json['StaticTexts'] ?? <String, dynamic>{};
    final rawSystemSettings = json['systemSettings'] ?? json['SystemSettings'] ?? <String, dynamic>{};

    final staticTexts = <String, String>{};
    if (rawStaticTexts is Map) {
      for (final entry in rawStaticTexts.entries) {
        staticTexts[entry.key.toString()] = entry.value?.toString() ?? '';
      }
    }

    final systemSettings = <String, Map<String, _AppSystemSetting>>{};
    if (rawSystemSettings is Map) {
      for (final sectionEntry in rawSystemSettings.entries) {
        final sectionValue = sectionEntry.value;
        if (sectionValue is! Map) {
          continue;
        }

        final sectionSettings = <String, _AppSystemSetting>{};
        for (final settingEntry in sectionValue.entries) {
          final settingValue = settingEntry.value;
          if (settingValue is Map<String, dynamic>) {
            sectionSettings[settingEntry.key.toString()] = _AppSystemSetting.fromJson(settingValue);
          } else if (settingValue is Map) {
            sectionSettings[settingEntry.key.toString()] = _AppSystemSetting.fromJson(
              settingValue.map((key, value) => MapEntry(key.toString(), value)),
            );
          }
        }

        systemSettings[sectionEntry.key.toString()] = sectionSettings;
      }
    }

    return _AppConfigPayload(
      staticTexts: staticTexts,
      systemSettings: systemSettings,
    );
  }
}

class AppConfigService {
  static const String communityGuidelinesSectionsKey = 'legal.community_guidelines.sections_json';
  static const String firstLaunchDialogTitleKey = 'legal.first_launch.dialog.title';
  static const String firstLaunchDialogIntroKey = 'legal.first_launch.dialog.intro';
  static const String firstLaunchDialogPrivacyCheckboxPrefixKey = 'legal.first_launch.dialog.privacy_checkbox_prefix';
  static const String firstLaunchDialogTermsCheckboxPrefixKey = 'legal.first_launch.dialog.terms_checkbox_prefix';
  static const String firstLaunchDialogDeclineTipPrefixKey = 'legal.first_launch.dialog.decline_tip_prefix';
  static const String firstLaunchDialogDeclineTipLinkSeparatorKey = 'legal.first_launch.dialog.decline_tip_link_separator';
  static const String firstLaunchDialogDeclineTipLinkFinalConnectorKey =
      'legal.first_launch.dialog.decline_tip_link_final_connector';
  static const String firstLaunchDialogDeclineTipSuffixKey = 'legal.first_launch.dialog.decline_tip_suffix';
  static const String firstLaunchDialogSdkLinkLabelKey = 'legal.first_launch.dialog.sdk_link_label';
  static const String firstLaunchDialogAgreeButtonKey = 'legal.first_launch.dialog.agree_button';
  static const String firstLaunchDialogRejectButtonKey = 'legal.first_launch.dialog.reject_button';
  static const String firstLaunchDialogSummaryFallbackTitleKey = 'legal.first_launch.dialog.summary_fallback_title';
  static const String firstLaunchDialogSummaryFallbackContentKey = 'legal.first_launch.dialog.summary_fallback_content';
  static const String firstLaunchDialogUncheckedToastTitleKey = 'legal.first_launch.dialog.unchecked_toast_title';
  static const String firstLaunchDialogUncheckedToastMessageKey = 'legal.first_launch.dialog.unchecked_toast_message';
  static const String firstLaunchDialogDeclineConfirmTitleKey = 'legal.first_launch.dialog.decline_confirm_title';
  static const String firstLaunchDialogDeclineConfirmMessageKey = 'legal.first_launch.dialog.decline_confirm_message';
  static const String firstLaunchDialogDeclineConfirmCancelKey = 'legal.first_launch.dialog.decline_confirm_cancel';
  static const String firstLaunchDialogDeclineConfirmExitKey = 'legal.first_launch.dialog.decline_confirm_exit';
  static const String forgotPasswordAccountStepTitleKey = 'auth.forgot_password.step.account.title';
  static const String forgotPasswordAccountStepDescriptionKey = 'auth.forgot_password.step.account.description';
  static const String forgotPasswordAccountInputLabelKey = 'auth.forgot_password.step.account.input_label';
  static const String forgotPasswordAccountSendCodeButtonKey = 'auth.forgot_password.step.account.send_code_button';
  static const String forgotPasswordVerifyStepTitleKey = 'auth.forgot_password.step.verify.title';
  static const String forgotPasswordVerifyStepDescriptionTemplateKey = 'auth.forgot_password.step.verify.description_template';
  static const String forgotPasswordVerifyCodeLabelKey = 'auth.forgot_password.step.verify.code_label';
  static const String forgotPasswordVerifyResendCountdownTemplateKey = 'auth.forgot_password.step.verify.resend_countdown_template';
  static const String forgotPasswordVerifyResendButtonKey = 'auth.forgot_password.step.verify.resend_button';
  static const String forgotPasswordVerifyNextButtonKey = 'auth.forgot_password.step.verify.next_button';
  static const String forgotPasswordResetStepTitleKey = 'auth.forgot_password.step.reset.title';
  static const String forgotPasswordResetStepDescriptionKey = 'auth.forgot_password.step.reset.description';
  static const String forgotPasswordResetNewPasswordLabelKey = 'auth.forgot_password.step.reset.new_password_label';
  static const String forgotPasswordResetConfirmPasswordLabelKey = 'auth.forgot_password.step.reset.confirm_password_label';
  static const String forgotPasswordResetSubmitButtonKey = 'auth.forgot_password.step.reset.submit_button';
  static const String forgotPasswordToastAccountRequiredKey = 'auth.forgot_password.toast.account_required';
  static const String forgotPasswordToastCodeSentEmailKey = 'auth.forgot_password.toast.code_sent_email';
  static const String forgotPasswordToastCodeSentPhoneKey = 'auth.forgot_password.toast.code_sent_phone';
  static const String forgotPasswordToastSendFailedFallbackKey = 'auth.forgot_password.toast.send_failed_fallback';
  static const String forgotPasswordToastCodeRequiredKey = 'auth.forgot_password.toast.code_required';
  static const String forgotPasswordToastCodeIncompleteKey = 'auth.forgot_password.toast.code_incomplete';
  static const String forgotPasswordToastNewPasswordRequiredKey = 'auth.forgot_password.toast.new_password_required';
  static const String forgotPasswordToastPasswordMinLengthKey = 'auth.forgot_password.toast.password_min_length';
  static const String forgotPasswordToastConfirmPasswordRequiredKey = 'auth.forgot_password.toast.confirm_password_required';
  static const String forgotPasswordToastPasswordMismatchKey = 'auth.forgot_password.toast.password_mismatch';
  static const String forgotPasswordToastResetSuccessKey = 'auth.forgot_password.toast.reset_success';
  static const String forgotPasswordToastResetFailedFallbackKey = 'auth.forgot_password.toast.reset_failed_fallback';
  static const String loginTermsPrefixKey = 'auth.login.terms.prefix';
  static const String loginTermsConnectorKey = 'auth.login.terms.connector';
  static const String loginTermsSuffixKey = 'auth.login.terms.suffix';
  static const String registerTermsPrefixKey = 'auth.register.terms.prefix';
  static const String registerTermsConnectorKey = 'auth.register.terms.connector';
  static const String registerTermsCommunityPrefixKey = 'auth.register.terms.community_prefix';
  static const String registerTermsSuffixKey = 'auth.register.terms.suffix';
  static const String legalLinksPrefixKey = 'auth.legal_links.prefix';
  static const String legalLinksConnectorKey = 'auth.legal_links.connector';
  static const String legalLinksSuffixKey = 'auth.legal_links.suffix';
  static const String brandLoadingTitleKey = 'brand.loading.title';
  static const String brandLoadingTaglineKey = 'brand.loading.tagline';
  static const String brandFooterCopyrightKey = 'brand.footer.copyright';
  static const String brandFooterIcpRecordKey = 'brand.footer.icp_record';
  static const String loginHeaderTitleKey = 'auth.login.header.title';
  static const String loginHeaderSubtitleKey = 'auth.login.header.subtitle';
  static const String loginRegisterLinkPrefixKey = 'auth.login.link.register_prefix';
  static const String loginCommunityTitleKey = 'auth.login.community.title';
  static const String loginCommunitySubtitleKey = 'auth.login.community.subtitle';
  static const String loginCommunityBadgeMeetupsKey = 'auth.login.community.badge.meetups';
  static const String loginCommunityBadgeMessagesKey = 'auth.login.community.badge.messages';
  static const String loginCommunityBadgeCitiesKey = 'auth.login.community.badge.cities';
  static const String loginFormEmailTabLabelKey = 'auth.login.form.tab.email';
  static const String loginFormPhoneTabLabelKey = 'auth.login.form.tab.phone';
  static const String loginFormEmailLabelKey = 'auth.login.form.email.label';
  static const String loginFormEmailHintKey = 'auth.login.form.email.hint';
  static const String loginFormPasswordLabelKey = 'auth.login.form.password.label';
  static const String loginFormPasswordHintKey = 'auth.login.form.password.hint';
  static const String loginFormRememberMeKey = 'auth.login.form.remember_me';
  static const String loginFormForgotPasswordKey = 'auth.login.form.forgot_password';
  static const String loginFormEmailSubmitButtonKey = 'auth.login.form.submit_email_button';
  static const String loginFormPhoneLabelKey = 'auth.login.form.phone.label';
  static const String loginFormPhoneHintKey = 'auth.login.form.phone.hint';
  static const String loginFormSmsCodeLabelKey = 'auth.login.form.sms_code.label';
  static const String loginFormSmsCodeHintKey = 'auth.login.form.sms_code.hint';
  static const String loginFormSmsCodeSendButtonKey = 'auth.login.form.sms_code.send_button';
  static const String loginFormSmsCodeCountdownTemplateKey = 'auth.login.form.sms_code.countdown_template';
  static const String loginFormPhoneSubmitButtonKey = 'auth.login.form.submit_phone_button';
  static const String loginFormEmailRequiredErrorKey = 'auth.login.form.error.email_required';
  static const String loginFormEmailInvalidErrorKey = 'auth.login.form.error.email_invalid';
  static const String loginFormPasswordRequiredErrorKey = 'auth.login.form.error.password_required';
  static const String loginFormPhoneRequiredErrorKey = 'auth.login.form.error.phone_required';
  static const String loginFormPhoneInvalidErrorKey = 'auth.login.form.error.phone_invalid';
  static const String loginFormSmsCodeRequiredErrorKey = 'auth.login.form.error.sms_code_required';
  static const String loginFeedbackTermsRequiredTitleKey = 'auth.login.feedback.terms_required_title';
  static const String loginFeedbackTermsRequiredMessageKey = 'auth.login.feedback.terms_required_message';
  static const String loginFeedbackPhoneRequiredKey = 'auth.login.feedback.phone_required';
  static const String loginFeedbackPhoneInvalidKey = 'auth.login.feedback.phone_invalid';
  static const String loginFeedbackSmsCodeSentKey = 'auth.login.feedback.sms_code_sent';
  static const String loginFeedbackSendFailedKey = 'auth.login.feedback.send_failed';
  static const String loginFeedbackSendSmsFailedKey = 'auth.login.feedback.send_sms_failed';
  static const String loginFeedbackWelcomeBackKey = 'auth.login.feedback.welcome_back';
  static const String loginFeedbackLoginSuccessTitleKey = 'auth.login.feedback.login_success_title';
  static const String loginFeedbackInvalidEmailOrPasswordKey = 'auth.login.feedback.invalid_email_or_password';
  static const String loginFeedbackLoginFailedTitleKey = 'auth.login.feedback.login_failed_title';
  static const String loginFeedbackUnknownErrorRetryKey = 'auth.login.feedback.unknown_error_retry';
  static const String loginFeedbackLoginFailedRetryKey = 'auth.login.feedback.login_failed_retry';
  static const String loginFeedbackSmsCodeInvalidOrExpiredKey = 'auth.login.feedback.sms_code_invalid_or_expired';
  static const String loginFeedbackSocialLoadingTitleTemplateKey =
      'auth.login.feedback.social_loading_title_template';
  static const String loginFeedbackPleaseWaitKey = 'auth.login.feedback.please_wait';
  static const String loginFeedbackSocialFailedTemplateKey = 'auth.login.feedback.social_failed_template';
  static const String loginSocialDividerKey = 'auth.login.social.divider';
  static const String loginSocialWechatLabelKey = 'auth.login.social.label.wechat';
  static const String loginSocialQqLabelKey = 'auth.login.social.label.qq';
  static const String loginSocialAppleLabelKey = 'auth.login.social.label.apple';
  static const String loginSocialGoogleLabelKey = 'auth.login.social.label.google';
  static const String loginSocialTwitterLabelKey = 'auth.login.social.label.twitter';
  static const String loginSocialFacebookLabelKey = 'auth.login.social.label.facebook';
  static const String loginSocialFacebookUnavailableTitleKey = 'auth.login.social.facebook_unavailable_title';
  static const String loginSocialFacebookUnavailableMessageKey = 'auth.login.social.facebook_unavailable_message';
  static const String registerHeaderTitleKey = 'auth.register.header.title';
  static const String registerHeaderSubtitleKey = 'auth.register.header.subtitle';
  static const String registerLoginLinkPrefixKey = 'auth.register.link.login_prefix';
  static const String registerHighlightsTitleKey = 'auth.register.highlights.title';
  static const String registerHighlightsMeetupsTitleKey = 'auth.register.highlights.meetups.title';
  static const String registerHighlightsMeetupsSubtitleKey = 'auth.register.highlights.meetups.subtitle';
  static const String registerHighlightsPeopleTitleKey = 'auth.register.highlights.people.title';
  static const String registerHighlightsPeopleSubtitleKey = 'auth.register.highlights.people.subtitle';
  static const String registerHighlightsDestinationsTitleKey = 'auth.register.highlights.destinations.title';
  static const String registerHighlightsDestinationsSubtitleKey = 'auth.register.highlights.destinations.subtitle';
  static const String registerHighlightsChatTitleKey = 'auth.register.highlights.chat.title';
  static const String registerHighlightsChatSubtitleKey = 'auth.register.highlights.chat.subtitle';
  static const String registerHighlightsTravelsTitleKey = 'auth.register.highlights.travels.title';
  static const String registerHighlightsTravelsSubtitleKey = 'auth.register.highlights.travels.subtitle';
  static const String registerFormUsernameLabelKey = 'auth.register.form.username.label';
  static const String registerFormUsernameHintKey = 'auth.register.form.username.hint';
  static const String registerFormEmailLabelKey = 'auth.register.form.email.label';
  static const String registerFormEmailHintKey = 'auth.register.form.email.hint';
  static const String registerFormVerificationCodeLabelKey = 'auth.register.form.verification_code.label';
  static const String registerFormVerificationCodeHintKey = 'auth.register.form.verification_code.hint';
  static const String registerFormVerificationCodeSendButtonKey = 'auth.register.form.verification_code.send_button';
    static const String registerFormVerificationCodeCountdownTemplateKey =
      'auth.register.form.verification_code.countdown_template';
  static const String registerFormVerificationCodeResendButtonKey =
      'auth.register.form.verification_code.resend_button';
  static const String registerFormPasswordLabelKey = 'auth.register.form.password.label';
  static const String registerFormPasswordHintKey = 'auth.register.form.password.hint';
  static const String registerFormConfirmPasswordLabelKey = 'auth.register.form.confirm_password.label';
  static const String registerFormConfirmPasswordHintKey = 'auth.register.form.confirm_password.hint';
  static const String registerFormSubmitButtonKey = 'auth.register.form.submit_button';
  static const String registerFormToastTermsRequiredTitleKey = 'auth.register.form.toast.terms_required_title';
  static const String registerFormToastTermsRequiredMessageKey = 'auth.register.form.toast.terms_required_message';
  static const String registerFormToastWelcomeMessageKey = 'auth.register.form.toast.welcome_message';
  static const String registerFormToastSuccessTitleKey = 'auth.register.form.toast.success_title';
    static const String registerFormUsernameRequiredErrorKey = 'auth.register.form.error.username_required';
    static const String registerFormUsernameMinLengthErrorKey = 'auth.register.form.error.username_min_length';
    static const String registerFormEmailRequiredErrorKey = 'auth.register.form.error.email_required';
    static const String registerFormEmailInvalidErrorKey = 'auth.register.form.error.email_invalid';
    static const String registerFormVerificationCodeRequiredErrorKey =
      'auth.register.form.error.verification_code_required';
    static const String registerFormVerificationCodeLengthErrorKey =
      'auth.register.form.error.verification_code_length';
    static const String registerFormPasswordRequiredErrorKey = 'auth.register.form.error.password_required';
    static const String registerFormPasswordMinLengthErrorKey = 'auth.register.form.error.password_min_length';
    static const String registerFormConfirmPasswordRequiredErrorKey =
      'auth.register.form.error.confirm_password_required';
    static const String registerFormPasswordsNotMatchErrorKey = 'auth.register.form.error.passwords_not_match';
    static const String registerFeedbackCodeSentToEmailKey = 'auth.register.feedback.code_sent_to_email';
    static const String registerFeedbackSendFailedKey = 'auth.register.feedback.send_failed';
    static const String registerFeedbackSendCodeFailedRetryKey = 'auth.register.feedback.send_code_failed_retry';
    static const String registerFeedbackRegisterFailedCheckInputKey =
      'auth.register.feedback.register_failed_check_input';
    static const String registerFeedbackRegisterFailedTitleKey = 'auth.register.feedback.register_failed_title';
    static const String registerFeedbackRegisterFailedProcessErrorKey =
      'auth.register.feedback.register_failed_process_error';
  static const String locationPermissionPurposeDialogKey = 'permission.location.purpose_dialog_json';
  static const String calendarPermissionPurposeDialogKey = 'permission.calendar.purpose_dialog_json';
  static const String notificationPermissionPurposeDialogKey = 'permission.notification.purpose_dialog_json';
  static const String locationPermissionDialogTitleKey = 'permission.location.dialog.title';
  static const String locationPermissionDialogDescriptionKey = 'permission.location.dialog.description';
  static const String locationPermissionDialogCancelButtonKey = 'permission.location.dialog.cancel_button';
  static const String locationPermissionDialogConfirmButtonKey = 'permission.location.dialog.confirm_button';
  static const String locationPermissionStatusLoadingKey = 'permission.location.status.loading';
  static const String locationPermissionStatusDisabledKey = 'permission.location.status.disabled';
  static const String locationPermissionStatusEnableActionKey = 'permission.location.status.enable_action';
  static const String legalDocumentsSection = 'legal_documents';
  static const String privacyPolicyVersionKey = 'privacy_policy_version';
  static const String termsOfServiceVersionKey = 'terms_of_service_version';

  static final AppConfigService _instance = AppConfigService._internal();

  factory AppConfigService() => _instance;

  AppConfigService._internal();

  final HttpService _http = HttpService();
  _AppConfigPayload? _cachedConfig;
  String? _cachedLocale;

  Future<_AppConfigPayload?> _getConfig({String? locale, bool forceRefresh = false}) async {
    final resolvedLocale = locale ?? _resolveLocale();
    if (!forceRefresh && _cachedConfig != null && _cachedLocale == resolvedLocale) {
      return _cachedConfig;
    }

    try {
      final response = await _http.get(
        '/app/config',
        queryParameters: {'locale': resolvedLocale},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        _cachedConfig = _AppConfigPayload.fromJson(data);
        _cachedLocale = resolvedLocale;
        return _cachedConfig;
      }

      if (data is Map) {
        final normalized = data.map((key, value) => MapEntry(key.toString(), value));
        _cachedConfig = _AppConfigPayload.fromJson(normalized);
        _cachedLocale = resolvedLocale;
        return _cachedConfig;
      }
    } catch (e) {
      log('⚠️ 获取 app/config 失败: $e');
    }

    return _cachedConfig;
  }

  Future<String?> getStaticText(
    String key, {
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return config?.staticTexts[key];
  }

  Future<String?> getSystemSettingValue(
    String section,
    String key, {
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return config?.systemSettings[section]?[key]?.value;
  }

  Future<LegalConsentVersions> getLegalConsentVersions({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final privacyPolicyVersion = await getSystemSettingValue(
      legalDocumentsSection,
      privacyPolicyVersionKey,
      locale: locale,
      forceRefresh: forceRefresh,
    );
    final termsOfServiceVersion = await getSystemSettingValue(
      legalDocumentsSection,
      termsOfServiceVersionKey,
      locale: locale,
      forceRefresh: forceRefresh,
    );

    return LegalConsentVersions(
      privacyPolicyVersion: _normalizeValue(privacyPolicyVersion),
      termsOfServiceVersion: _normalizeValue(termsOfServiceVersion),
    );
  }

  FirstLaunchPrivacyDialogCopy _buildFirstLaunchPrivacyDialogCopy(_AppConfigPayload? config) {
    return FirstLaunchPrivacyDialogCopy(
      title: _normalizeStaticText(config, firstLaunchDialogTitleKey),
      intro: _normalizeStaticText(config, firstLaunchDialogIntroKey),
      privacyCheckboxPrefix: _normalizeStaticText(config, firstLaunchDialogPrivacyCheckboxPrefixKey),
      termsCheckboxPrefix: _normalizeStaticText(config, firstLaunchDialogTermsCheckboxPrefixKey),
      declineTipPrefix: _normalizeStaticText(config, firstLaunchDialogDeclineTipPrefixKey),
      declineTipLinkSeparator: _normalizeStaticText(config, firstLaunchDialogDeclineTipLinkSeparatorKey),
      declineTipLinkFinalConnector: _normalizeStaticText(config, firstLaunchDialogDeclineTipLinkFinalConnectorKey),
      declineTipSuffix: _normalizeStaticText(config, firstLaunchDialogDeclineTipSuffixKey),
      sdkLinkLabel: _normalizeStaticText(config, firstLaunchDialogSdkLinkLabelKey),
      agreeButtonLabel: _normalizeStaticText(config, firstLaunchDialogAgreeButtonKey),
      rejectButtonLabel: _normalizeStaticText(config, firstLaunchDialogRejectButtonKey),
      summaryFallbackTitle: _normalizeStaticText(config, firstLaunchDialogSummaryFallbackTitleKey),
      summaryFallbackContent: _normalizeStaticText(config, firstLaunchDialogSummaryFallbackContentKey),
      uncheckedToastTitle: _normalizeStaticText(config, firstLaunchDialogUncheckedToastTitleKey),
      uncheckedToastMessage: _normalizeStaticText(config, firstLaunchDialogUncheckedToastMessageKey),
      declineConfirmTitle: _normalizeStaticText(config, firstLaunchDialogDeclineConfirmTitleKey),
      declineConfirmMessage: _normalizeStaticText(config, firstLaunchDialogDeclineConfirmMessageKey),
      declineConfirmCancelLabel: _normalizeStaticText(config, firstLaunchDialogDeclineConfirmCancelKey),
      declineConfirmExitLabel: _normalizeStaticText(config, firstLaunchDialogDeclineConfirmExitKey),
    );
  }

  PreAuthMarketingCopy _buildPreAuthMarketingCopy(_AppConfigPayload? config) {
    return PreAuthMarketingCopy(
      loginHeaderTitle: _normalizeStaticText(config, loginHeaderTitleKey),
      loginHeaderSubtitle: _normalizeStaticText(config, loginHeaderSubtitleKey),
      loginRegisterLinkPrefix: _normalizeStaticText(config, loginRegisterLinkPrefixKey),
      loginCommunityTitle: _normalizeStaticText(config, loginCommunityTitleKey),
      loginCommunitySubtitle: _normalizeStaticText(config, loginCommunitySubtitleKey),
      loginCommunityBadgeMeetups: _normalizeStaticText(config, loginCommunityBadgeMeetupsKey),
      loginCommunityBadgeMessages: _normalizeStaticText(config, loginCommunityBadgeMessagesKey),
      loginCommunityBadgeCities: _normalizeStaticText(config, loginCommunityBadgeCitiesKey),
      registerHeaderTitle: _normalizeStaticText(config, registerHeaderTitleKey),
      registerHeaderSubtitle: _normalizeStaticText(config, registerHeaderSubtitleKey),
      registerLoginLinkPrefix: _normalizeStaticText(config, registerLoginLinkPrefixKey),
      registerHighlightsTitle: _normalizeStaticText(config, registerHighlightsTitleKey),
      registerHighlightsMeetupsTitle: _normalizeStaticText(config, registerHighlightsMeetupsTitleKey),
      registerHighlightsMeetupsSubtitle: _normalizeStaticText(config, registerHighlightsMeetupsSubtitleKey),
      registerHighlightsPeopleTitle: _normalizeStaticText(config, registerHighlightsPeopleTitleKey),
      registerHighlightsPeopleSubtitle: _normalizeStaticText(config, registerHighlightsPeopleSubtitleKey),
      registerHighlightsDestinationsTitle: _normalizeStaticText(config, registerHighlightsDestinationsTitleKey),
      registerHighlightsDestinationsSubtitle: _normalizeStaticText(config, registerHighlightsDestinationsSubtitleKey),
      registerHighlightsChatTitle: _normalizeStaticText(config, registerHighlightsChatTitleKey),
      registerHighlightsChatSubtitle: _normalizeStaticText(config, registerHighlightsChatSubtitleKey),
      registerHighlightsTravelsTitle: _normalizeStaticText(config, registerHighlightsTravelsTitleKey),
      registerHighlightsTravelsSubtitle: _normalizeStaticText(config, registerHighlightsTravelsSubtitleKey),
    );
  }

  LoginFormCopy _buildLoginFormCopy(_AppConfigPayload? config) {
    return LoginFormCopy(
      emailTabLabel: _normalizeStaticText(config, loginFormEmailTabLabelKey),
      phoneTabLabel: _normalizeStaticText(config, loginFormPhoneTabLabelKey),
      emailLabel: _normalizeStaticText(config, loginFormEmailLabelKey),
      emailHint: _normalizeStaticText(config, loginFormEmailHintKey),
      passwordLabel: _normalizeStaticText(config, loginFormPasswordLabelKey),
      passwordHint: _normalizeStaticText(config, loginFormPasswordHintKey),
      rememberMe: _normalizeStaticText(config, loginFormRememberMeKey),
      forgotPassword: _normalizeStaticText(config, loginFormForgotPasswordKey),
      emailSubmitButton: _normalizeStaticText(config, loginFormEmailSubmitButtonKey),
      phoneLabel: _normalizeStaticText(config, loginFormPhoneLabelKey),
      phoneHint: _normalizeStaticText(config, loginFormPhoneHintKey),
      smsCodeLabel: _normalizeStaticText(config, loginFormSmsCodeLabelKey),
      smsCodeHint: _normalizeStaticText(config, loginFormSmsCodeHintKey),
      smsCodeSendButton: _normalizeStaticText(config, loginFormSmsCodeSendButtonKey),
      smsCodeCountdownTemplate: _normalizeStaticText(config, loginFormSmsCodeCountdownTemplateKey),
      phoneSubmitButton: _normalizeStaticText(config, loginFormPhoneSubmitButtonKey),
      emailRequiredError: _normalizeStaticText(config, loginFormEmailRequiredErrorKey),
      emailInvalidError: _normalizeStaticText(config, loginFormEmailInvalidErrorKey),
      passwordRequiredError: _normalizeStaticText(config, loginFormPasswordRequiredErrorKey),
      phoneRequiredError: _normalizeStaticText(config, loginFormPhoneRequiredErrorKey),
      phoneInvalidError: _normalizeStaticText(config, loginFormPhoneInvalidErrorKey),
      smsCodeRequiredError: _normalizeStaticText(config, loginFormSmsCodeRequiredErrorKey),
    );
  }

  LoginFeedbackCopy _buildLoginFeedbackCopy(_AppConfigPayload? config) {
    return LoginFeedbackCopy(
      termsRequiredTitle: _normalizeStaticText(config, loginFeedbackTermsRequiredTitleKey),
      termsRequiredMessage: _normalizeStaticText(config, loginFeedbackTermsRequiredMessageKey),
      phoneRequiredMessage: _normalizeStaticText(config, loginFeedbackPhoneRequiredKey),
      phoneInvalidMessage: _normalizeStaticText(config, loginFeedbackPhoneInvalidKey),
      smsCodeSentMessage: _normalizeStaticText(config, loginFeedbackSmsCodeSentKey),
      sendFailedMessage: _normalizeStaticText(config, loginFeedbackSendFailedKey),
      sendSmsFailedMessage: _normalizeStaticText(config, loginFeedbackSendSmsFailedKey),
      welcomeBackMessage: _normalizeStaticText(config, loginFeedbackWelcomeBackKey),
      loginSuccessTitle: _normalizeStaticText(config, loginFeedbackLoginSuccessTitleKey),
      invalidEmailOrPasswordMessage: _normalizeStaticText(config, loginFeedbackInvalidEmailOrPasswordKey),
      loginFailedTitle: _normalizeStaticText(config, loginFeedbackLoginFailedTitleKey),
      unknownErrorRetryMessage: _normalizeStaticText(config, loginFeedbackUnknownErrorRetryKey),
      loginFailedRetryMessage: _normalizeStaticText(config, loginFeedbackLoginFailedRetryKey),
      smsCodeInvalidOrExpiredMessage: _normalizeStaticText(config, loginFeedbackSmsCodeInvalidOrExpiredKey),
      socialLoadingTitleTemplate: _normalizeStaticText(config, loginFeedbackSocialLoadingTitleTemplateKey),
      pleaseWaitMessage: _normalizeStaticText(config, loginFeedbackPleaseWaitKey),
      socialFailedTemplate: _normalizeStaticText(config, loginFeedbackSocialFailedTemplateKey),
    );
  }

  LoginSocialCopy _buildLoginSocialCopy(_AppConfigPayload? config) {
    return LoginSocialCopy(
      dividerLabel: _normalizeStaticText(config, loginSocialDividerKey),
      wechatLabel: _normalizeStaticText(config, loginSocialWechatLabelKey),
      qqLabel: _normalizeStaticText(config, loginSocialQqLabelKey),
      appleLabel: _normalizeStaticText(config, loginSocialAppleLabelKey),
      googleLabel: _normalizeStaticText(config, loginSocialGoogleLabelKey),
      twitterLabel: _normalizeStaticText(config, loginSocialTwitterLabelKey),
      facebookLabel: _normalizeStaticText(config, loginSocialFacebookLabelKey),
      facebookUnavailableTitle: _normalizeStaticText(config, loginSocialFacebookUnavailableTitleKey),
      facebookUnavailableMessage: _normalizeStaticText(config, loginSocialFacebookUnavailableMessageKey),
    );
  }

  RegisterFormCopy _buildRegisterFormCopy(_AppConfigPayload? config) {
    return RegisterFormCopy(
      usernameLabel: _normalizeStaticText(config, registerFormUsernameLabelKey),
      usernameHint: _normalizeStaticText(config, registerFormUsernameHintKey),
      emailLabel: _normalizeStaticText(config, registerFormEmailLabelKey),
      emailHint: _normalizeStaticText(config, registerFormEmailHintKey),
      verificationCodeLabel: _normalizeStaticText(config, registerFormVerificationCodeLabelKey),
      verificationCodeHint: _normalizeStaticText(config, registerFormVerificationCodeHintKey),
      verificationCodeSendButton: _normalizeStaticText(config, registerFormVerificationCodeSendButtonKey),
      verificationCodeCountdownTemplate: _normalizeStaticText(config, registerFormVerificationCodeCountdownTemplateKey),
      verificationCodeResendButton: _normalizeStaticText(config, registerFormVerificationCodeResendButtonKey),
      passwordLabel: _normalizeStaticText(config, registerFormPasswordLabelKey),
      passwordHint: _normalizeStaticText(config, registerFormPasswordHintKey),
      confirmPasswordLabel: _normalizeStaticText(config, registerFormConfirmPasswordLabelKey),
      confirmPasswordHint: _normalizeStaticText(config, registerFormConfirmPasswordHintKey),
      submitButton: _normalizeStaticText(config, registerFormSubmitButtonKey),
      termsRequiredTitle: _normalizeStaticText(config, registerFormToastTermsRequiredTitleKey),
      termsRequiredMessage: _normalizeStaticText(config, registerFormToastTermsRequiredMessageKey),
      welcomeToastMessage: _normalizeStaticText(config, registerFormToastWelcomeMessageKey),
      successTitle: _normalizeStaticText(config, registerFormToastSuccessTitleKey),
      usernameRequiredError: _normalizeStaticText(config, registerFormUsernameRequiredErrorKey),
      usernameMinLengthError: _normalizeStaticText(config, registerFormUsernameMinLengthErrorKey),
      emailRequiredError: _normalizeStaticText(config, registerFormEmailRequiredErrorKey),
      emailInvalidError: _normalizeStaticText(config, registerFormEmailInvalidErrorKey),
      verificationCodeRequiredError: _normalizeStaticText(config, registerFormVerificationCodeRequiredErrorKey),
      verificationCodeLengthError: _normalizeStaticText(config, registerFormVerificationCodeLengthErrorKey),
      passwordRequiredError: _normalizeStaticText(config, registerFormPasswordRequiredErrorKey),
      passwordMinLengthError: _normalizeStaticText(config, registerFormPasswordMinLengthErrorKey),
      confirmPasswordRequiredError: _normalizeStaticText(config, registerFormConfirmPasswordRequiredErrorKey),
      passwordsNotMatchError: _normalizeStaticText(config, registerFormPasswordsNotMatchErrorKey),
    );
  }

  RegisterFeedbackCopy _buildRegisterFeedbackCopy(_AppConfigPayload? config) {
    return RegisterFeedbackCopy(
      codeSentToEmailMessage: _normalizeStaticText(config, registerFeedbackCodeSentToEmailKey),
      sendFailedMessage: _normalizeStaticText(config, registerFeedbackSendFailedKey),
      sendCodeFailedRetryMessage: _normalizeStaticText(config, registerFeedbackSendCodeFailedRetryKey),
      registerFailedCheckInputMessage: _normalizeStaticText(config, registerFeedbackRegisterFailedCheckInputKey),
      registerFailedTitle: _normalizeStaticText(config, registerFeedbackRegisterFailedTitleKey),
      registerFailedProcessErrorMessage: _normalizeStaticText(config, registerFeedbackRegisterFailedProcessErrorKey),
    );
  }

  Future<FirstLaunchPrivacyDialogCopy> getFirstLaunchPrivacyDialogCopy({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return _buildFirstLaunchPrivacyDialogCopy(config);
  }

  Future<ForgotPasswordCopy> getForgotPasswordCopy({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return ForgotPasswordCopy(
      accountStepTitle: _normalizeStaticText(config, forgotPasswordAccountStepTitleKey),
      accountStepDescription: _normalizeStaticText(config, forgotPasswordAccountStepDescriptionKey),
      accountInputLabel: _normalizeStaticText(config, forgotPasswordAccountInputLabelKey),
      accountSendCodeButton: _normalizeStaticText(config, forgotPasswordAccountSendCodeButtonKey),
      verifyStepTitle: _normalizeStaticText(config, forgotPasswordVerifyStepTitleKey),
      verifyStepDescriptionTemplate: _normalizeStaticText(config, forgotPasswordVerifyStepDescriptionTemplateKey),
      verifyCodeLabel: _normalizeStaticText(config, forgotPasswordVerifyCodeLabelKey),
      verifyResendCountdownTemplate: _normalizeStaticText(config, forgotPasswordVerifyResendCountdownTemplateKey),
      verifyResendButton: _normalizeStaticText(config, forgotPasswordVerifyResendButtonKey),
      verifyNextButton: _normalizeStaticText(config, forgotPasswordVerifyNextButtonKey),
      resetStepTitle: _normalizeStaticText(config, forgotPasswordResetStepTitleKey),
      resetStepDescription: _normalizeStaticText(config, forgotPasswordResetStepDescriptionKey),
      resetNewPasswordLabel: _normalizeStaticText(config, forgotPasswordResetNewPasswordLabelKey),
      resetConfirmPasswordLabel: _normalizeStaticText(config, forgotPasswordResetConfirmPasswordLabelKey),
      resetSubmitButton: _normalizeStaticText(config, forgotPasswordResetSubmitButtonKey),
      toastAccountRequired: _normalizeStaticText(config, forgotPasswordToastAccountRequiredKey),
      toastCodeSentEmail: _normalizeStaticText(config, forgotPasswordToastCodeSentEmailKey),
      toastCodeSentPhone: _normalizeStaticText(config, forgotPasswordToastCodeSentPhoneKey),
      toastSendFailedFallback: _normalizeStaticText(config, forgotPasswordToastSendFailedFallbackKey),
      toastCodeRequired: _normalizeStaticText(config, forgotPasswordToastCodeRequiredKey),
      toastCodeIncomplete: _normalizeStaticText(config, forgotPasswordToastCodeIncompleteKey),
      toastNewPasswordRequired: _normalizeStaticText(config, forgotPasswordToastNewPasswordRequiredKey),
      toastPasswordMinLength: _normalizeStaticText(config, forgotPasswordToastPasswordMinLengthKey),
      toastConfirmPasswordRequired: _normalizeStaticText(config, forgotPasswordToastConfirmPasswordRequiredKey),
      toastPasswordMismatch: _normalizeStaticText(config, forgotPasswordToastPasswordMismatchKey),
      toastResetSuccess: _normalizeStaticText(config, forgotPasswordToastResetSuccessKey),
      toastResetFailedFallback: _normalizeStaticText(config, forgotPasswordToastResetFailedFallbackKey),
    );
  }

  Future<PreAuthLegalCopy> getPreAuthLegalCopy({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return PreAuthLegalCopy(
      loginTermsPrefix: _normalizeStaticText(config, loginTermsPrefixKey),
      loginTermsConnector: _normalizeStaticText(config, loginTermsConnectorKey),
      loginTermsSuffix: _normalizeStaticText(config, loginTermsSuffixKey),
      registerTermsPrefix: _normalizeStaticText(config, registerTermsPrefixKey),
      registerTermsConnector: _normalizeStaticText(config, registerTermsConnectorKey),
      registerTermsCommunityPrefix: _normalizeStaticText(config, registerTermsCommunityPrefixKey),
      registerTermsSuffix: _normalizeStaticText(config, registerTermsSuffixKey),
      legalLinksPrefix: _normalizeStaticText(config, legalLinksPrefixKey),
      legalLinksConnector: _normalizeStaticText(config, legalLinksConnectorKey),
      legalLinksSuffix: _normalizeStaticText(config, legalLinksSuffixKey),
    );
  }

  Future<PublicBrandingCopy> getPublicBrandingCopy({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return PublicBrandingCopy(
      loadingTitle: _normalizeStaticText(config, brandLoadingTitleKey),
      loadingTagline: _normalizeStaticText(config, brandLoadingTaglineKey),
      footerCopyright: _normalizeStaticText(config, brandFooterCopyrightKey),
      footerIcpRecord: _normalizeStaticText(config, brandFooterIcpRecordKey),
    );
  }

  Future<PreAuthMarketingCopy> getPreAuthMarketingCopy({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return _buildPreAuthMarketingCopy(config);
  }

  Future<LoginEntryCopyBundle> getLoginEntryCopyBundle({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return LoginEntryCopyBundle(
      marketing: _buildPreAuthMarketingCopy(config),
      form: _buildLoginFormCopy(config),
      feedback: _buildLoginFeedbackCopy(config),
      social: _buildLoginSocialCopy(config),
    );
  }

  Future<RegisterEntryCopyBundle> getRegisterEntryCopyBundle({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return RegisterEntryCopyBundle(
      marketing: _buildPreAuthMarketingCopy(config),
      form: _buildRegisterFormCopy(config),
      feedback: _buildRegisterFeedbackCopy(config),
    );
  }

  Future<PermissionPurposeCopy?> getLocationPermissionPurposeCopy({
    String? locale,
    bool forceRefresh = false,
  }) {
    return _getPermissionPurposeCopy(
      locationPermissionPurposeDialogKey,
      locale: locale,
      forceRefresh: forceRefresh,
    );
  }

  Future<PermissionPurposeCopy?> getCalendarPermissionPurposeCopy({
    String? locale,
    bool forceRefresh = false,
  }) {
    return _getPermissionPurposeCopy(
      calendarPermissionPurposeDialogKey,
      locale: locale,
      forceRefresh: forceRefresh,
    );
  }

  Future<PermissionPurposeCopy?> getNotificationPermissionPurposeCopy({
    String? locale,
    bool forceRefresh = false,
  }) {
    return _getPermissionPurposeCopy(
      notificationPermissionPurposeDialogKey,
      locale: locale,
      forceRefresh: forceRefresh,
    );
  }

  Future<LocationPermissionUiCopy> getLocationPermissionUiCopy({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final config = await _getConfig(locale: locale, forceRefresh: forceRefresh);
    return LocationPermissionUiCopy(
      dialogTitle: _normalizeStaticText(config, locationPermissionDialogTitleKey),
      dialogDescription: _normalizeStaticText(config, locationPermissionDialogDescriptionKey),
      dialogCancelButton: _normalizeStaticText(config, locationPermissionDialogCancelButtonKey),
      dialogConfirmButton: _normalizeStaticText(config, locationPermissionDialogConfirmButtonKey),
      statusLoading: _normalizeStaticText(config, locationPermissionStatusLoadingKey),
      statusDisabled: _normalizeStaticText(config, locationPermissionStatusDisabledKey),
      statusEnableAction: _normalizeStaticText(config, locationPermissionStatusEnableActionKey),
    );
  }

  Future<PermissionPurposeCopy?> _getPermissionPurposeCopy(
    String key, {
    String? locale,
    bool forceRefresh = false,
  }) async {
    final raw = await getStaticText(
      key,
      locale: locale,
      forceRefresh: forceRefresh,
    );
    final normalized = _normalizeValue(raw);
    if (normalized == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is! Map) {
        return null;
      }

      final title = decoded['title']?.toString().trim();
      final description = decoded['description']?.toString().trim();
      final note = decoded['note']?.toString().trim();
      final confirmText = decoded['confirmText']?.toString().trim();

      final purposes = <String>[];
      final rawPurposes = decoded['purposes'];
      if (rawPurposes is List) {
        for (final item in rawPurposes) {
          final text = item?.toString().trim() ?? '';
          if (text.isNotEmpty) {
            purposes.add(text);
          }
        }
      }

      return PermissionPurposeCopy(
        title: _normalizeValue(title),
        description: _normalizeValue(description),
        purposes: purposes,
        note: _normalizeValue(note),
        confirmText: _normalizeValue(confirmText),
      );
    } catch (e) {
      log('⚠️ 解析权限用途说明配置失败: $e');
      return null;
    }
  }

  Future<List<AppConfigSection>?> getCommunityGuidelineSections({
    String? locale,
    bool forceRefresh = false,
  }) async {
    final raw = await getStaticText(
      communityGuidelinesSectionsKey,
      locale: locale,
      forceRefresh: forceRefresh,
    );
    final normalized = _normalizeValue(raw);
    if (normalized == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is! List) {
        return null;
      }

      final sections = <AppConfigSection>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }

        final title = item['title']?.toString().trim() ?? '';
        final content = item['content']?.toString().trim() ?? '';
        if (title.isEmpty || content.isEmpty) {
          continue;
        }

        sections.add(AppConfigSection(title: title, content: content));
      }

      return sections.isEmpty ? null : sections;
    } catch (e) {
      log('⚠️ 解析社区准则配置失败: $e');
      return null;
    }
  }

  String _resolveLocale() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final languageCode = locale.languageCode.trim();
    final countryCode = locale.countryCode?.trim();

    if (languageCode.isEmpty) {
      return 'zh-CN';
    }
    if (countryCode != null && countryCode.isNotEmpty) {
      return '$languageCode-$countryCode';
    }
    if (languageCode == 'zh') {
      return 'zh-CN';
    }
    if (languageCode == 'en') {
      return 'en-US';
    }
    return languageCode;
  }

  static String? _normalizeValue(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _normalizeStaticText(_AppConfigPayload? config, String key) {
    return _normalizeValue(config?.staticTexts[key]);
  }
}
