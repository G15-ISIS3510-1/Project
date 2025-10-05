package com.example.kotlinapp.core.work

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.navigation.NavDeepLinkBuilder
import androidx.work.CoroutineWorker
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.example.kotlinapp.R
import com.example.kotlinapp.MainActivity 
import java.util.concurrent.TimeUnit

class LoginReminderWorker(
    appContext: Context,
    params: WorkerParameters
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        ensureChannel()
        
        val contentIntent: PendingIntent = NavDeepLinkBuilder(applicationContext)
            .setComponentName(MainActivity::class.java) // Activity con tu NavHostFragment
            .setGraph(R.navigation.nav_graph)          
            .setDestination(R.id.homeFragment)      
            .createPendingIntent()

        val notif = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("¡Te espera una reserva nueva!")
            .setContentText("Hace 1 hora iniciaste sesión. Vuelve y revisa las opciones disponibles.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(contentIntent)
            .build()

        NotificationManagerCompat.from(applicationContext).notify(NOTIF_ID, notif)
        return Result.success()
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

        /** Programa el recordatorio para dentro de [delayMinutes] minutos (60 por defecto). */
        fun schedule(context: Context, delayMinutes: Long = 60) {
            val req = OneTimeWorkRequestBuilder<LoginReminderWorker>()
                .setInitialDelay(delayMinutes, TimeUnit.MINUTES)
                .build()

            WorkManager.getInstance(context).enqueueUniqueWork(
                UNIQUE_WORK_NAME,
                ExistingWorkPolicy.REPLACE, // si vuelve a loguearse, se reprograma
                req
            )
        }

        /** (Opcional) cancelar, por ejemplo en logout */
        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_WORK_NAME)
        }
        
    }
}
