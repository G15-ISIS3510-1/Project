pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()       // Repositorio de Android (para Room, Material, etc.)
        mavenCentral() // Repositorio general (OkHttp, Coroutines, etc.)
    }
}

// Nombre del proyecto raíz
rootProject.name = "KotlinApp"

// Módulos incluidos
include(":app")
