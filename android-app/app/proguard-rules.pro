# ProGuard rules for ScamShield Android App
-keepattributes JavaScriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
