package com.devsoc.freerooms

import android.app.Application
import com.devsoc.freerooms.core.di.AppContainer

class MainApplication : Application() {
    val appContainer = AppContainer()
}
