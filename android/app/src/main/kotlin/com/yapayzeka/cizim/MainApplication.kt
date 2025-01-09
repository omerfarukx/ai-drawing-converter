package com.yapayzeka.cizim

import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class MainApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        
        val flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        FlutterEngineCache
            .getInstance()
            .put("my_engine_id", flutterEngine)
    }
} 