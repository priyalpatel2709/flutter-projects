package com.download.school_pdf

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.view.LayoutInflater
import android.widget.TextView   // <-- add this
import android.widget.ImageView // <-- if you use icon/media
import android.widget.Button    // <-- if you use CTA button

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register Native Template Factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeTemplateStyle",
            NativeTemplateAdFactory(layoutInflater)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeTemplateStyle")
    }
}

internal class NativeTemplateAdFactory(private val inflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = inflater.inflate(
            R.layout.native_ad_layout, // your custom layout
            null
        ) as NativeAdView

        // Example: Headline
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
