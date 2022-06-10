package com.example.swallowapps;
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.view.FlutterMain

class Application:FlutterApplication(), PluginRegistrantCallback{
    override fun onCreate(){
        super.onCreate()
        FlutterMain.startInitialization(this)
    }

    override fun registerWith(registry: PluginRegistry){
        if(!registry!!.hasPlugin("io.flutter.plugins.firebasemessaging")){
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
        }
        if(!registry!!.hasPlugin("com.dexterous.flutterlocalnotifications")){
            FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))
        }
    }
}