    // --- BLOQUE AÑADIDO PARA DEFINIR LA VERSIÓN CORRECTA ---
    buildscript {
        repositories {
            google()
            mavenCentral()
        }
        dependencies {
            // Esta es la versión compatible que solucionará el error
            classpath "com.android.tools.build:gradle:7.3.1"
            // La versión de Kotlin que usa Flutter
            classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22"
        }
    }
    // --- FIN DEL BLOQUE AÑADIDO ---

    allprojects {
        repositories {
            google()
            mavenCentral()
        }
    }

    val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
    rootProject.layout.buildDirectory.value(newBuildDir)

    subprojects {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
    subprojects {
        project.evaluationDependsOn(":app")
    }

    tasks.register<Delete>("clean") {
        delete(rootProject.layout.buildDirectory)
    }
    