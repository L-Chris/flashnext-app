# Only the fixed WebView readiness bridge is visible to JavaScript.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
