package com.devsoc.freerooms

import android.app.Application
import org.koin.android.ext.koin.androidContext
import org.koin.core.annotation.ComponentScan
import org.koin.core.annotation.KoinApplication
import org.koin.plugin.module.dsl.startKoin

@KoinApplication
@ComponentScan("com.devsoc")
class MyApp

class FreeroomsApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin<MyApp> {
            androidContext(this@FreeroomsApplication)
            allowOverride(false)
        }
    }
}
