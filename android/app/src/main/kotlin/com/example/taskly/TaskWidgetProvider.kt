package com.example.taskly

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class TaskWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.task_widget).apply {
                val listName = widgetData.getString("list_name", "My Tasks")
                
                setTextViewText(R.id.appwidget_title, listName)

                // Open App on List Title Click (Show Lists)
                val listIntent = Intent(context, MainActivity::class.java)
                listIntent.action = Intent.ACTION_VIEW
                listIntent.data = Uri.parse("taskly://openlists")
                listIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                val listPendingIntent = PendingIntent.getActivity(
                    context, 
                    0, 
                    listIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_title_container, listPendingIntent)

                // Open App on Add Click (New Task)
                val addIntent = Intent(context, MainActivity::class.java)
                addIntent.action = Intent.ACTION_VIEW
                addIntent.data = Uri.parse("taskly://opentask")
                addIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                val addPendingIntent = PendingIntent.getActivity(
                    context, 
                    1, 
                    addIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_add_button, addPendingIntent)
                // Configure ListView
                val serviceIntent = Intent(context, TaskWidgetService::class.java)
                serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
                
                setRemoteAdapter(R.id.widget_list_view, serviceIntent)
                setEmptyView(R.id.widget_list_view, R.id.widget_empty_view)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list_view)
        }
    }
}
