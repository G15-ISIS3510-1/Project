package com.example.kotlinapp.core.work

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.navigation.NavDeepLinkBuilder
import androidx.work.*
import com.example.kotlinapp.R
import com.example.kotlinapp.MainActivity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

/**
 * Worker que programa una notificación una hora después de iniciar sesión,
 * si el usuario no ha realizado una reserva.
 *
 * Estrategia de Concurrencia aplicada:
 * - Uso de WorkManager + CoroutineWorker para ejecutar la tarea fuera del Main Thread.
 * - withContext(Dispatchers.IO) para asegurar la ejecución en un hilo de I/O.
 * - enqueueUniqueWork para evitar trabajos duplicados.
 */
class LoginReminderWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            ensureChannel()

            // Crear un PendingIntent hacia el HomeFragment
            val contentIntent: PendingIntent = NavDeepLinkBuilder(applicationContext)
                .setComponentName(MainActivity::class.java)
                .setGraph(R.navigation.nav_graph)
                .setDestination(R.id.homeFragment)
                .createPendingIntent()

            // Construcción de la notificación
            val notif = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle("¡Te espera una reserva nueva!")
                .setContentText("Hace 1 hora iniciaste sesión. Vuelve y revisa las opciones disponibles.")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(contentIntent)
                .build()

            NotificationManagerCompat.from(applicationContext).notify(NOTIF_ID, notif)
            Result.success()
        } catch (e: Exception) {
            e.printStackTrace()
            Result.failure()
        }
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "Recordatorios tras login",
                    NotificationManager.IMPORTANCE_HIGH
                )
            )
        }
    }

    companion object {
        private const val CHANNEL_ID = "login_reminders"
        private const val UNIQUE_WORK_NAME = "login_reminder_unique"
        private const val NOTIF_ID = 1001

        /**
         * Programa el recordatorio para dentro de [delayMinutes] minutos (por defecto, 60).
         * Usa enqueueUniqueWork para evitar duplicados.
         */
        fun schedule(context: Context, delayMinutes: Long = 60L) {
            val req = OneTimeWorkRequestBuilder<LoginReminderWorker>()
                .setInitialDelay(delayMinutes, TimeUnit.MINUTES)
                .build()

            WorkManager.getInstance(context).enqueueUniqueWork(
                UNIQUE_WORK_NAME,
                ExistingWorkPolicy.REPLACE,
                req
            )
        }

        /** Cancela el trabajo (por ejemplo, al cerrar sesión o reautenticarse). */
        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_WORK_NAME)
        }
    }
}


