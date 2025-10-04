bool isNightNow(DateTime now, {int startHour = 19, int endHour = 6}) {
  // Soporta ventanas que cruzan medianoche (e.g., 19:00–06:00)
  final h = now.hour;
  if (startHour <= endHour) {
    // ventana sin cruce de medianoche (p.ej. 18–22)
    return h >= startHour && h < endHour;
  } else {
    // ventana con cruce de medianoche (p.ej. 19–06)
    return h >= startHour || h < endHour;
  }
}
