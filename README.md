# 🎣 Nature Fly Fishing Competition

App para Apple Watch diseñada para competiciones de pesca con mosca. Permite cronometrar sesiones, registrar capturas por categoría, sincronizar con Apple Fitness y subir automáticamente los resultados a Strava.

---

## ✨ Funcionalidades

### 🏁 Modos de competición

- **Tiempo** ⏱ — Duración configurable de 10 a 120 minutos (en pasos de 10 min, por defecto 60). La sesión termina automáticamente al llegar a 0.
- **Libre** 🆓 — Sin límite de tiempo. El usuario decide cuándo finalizar.

### ⏱ Temporizador

- Cuenta atrás (modo Tiempo) o tiempo transcurrido (modo Libre)
- Controles de **Inicio / Pausa / Finalizar**
- Cambio de color progresivo según el tiempo restante:
  - `> 50%` → 🟢 verde
  - `20–50%` → 🟡 amarillo
  - `< 20%` → 🔴 rojo
- El timer sigue corriendo con la pantalla apagada gracias a `HKWorkoutSession`
- Las pausas se descuentan correctamente del tiempo de competición

### 🐟 Contadores de capturas

- **Peces T** — en rojo 🔴
- **Peces M** — en azul 🔵
- Botones `+` y `−` con feedback háptico
- No permiten valores negativos
- Accesibles deslizando desde el timer (TabView)

### 🏁 Fin de sesión

- Al llegar a 0 (modo Tiempo) o pulsar la bandera, la sesión se cierra automáticamente
- Resumen inmediato con duración, capturas y estado de sincronización

### 🍎 Apple Fitness (HealthKit)

- Guarda el entrenamiento como actividad de tipo **Other**
- Registra fecha/hora de inicio y fin
- Incluye metadatos de capturas y modo de sesión
- Solicita permisos en el primer uso
- Usa `HKWorkoutSession` + `HKLiveWorkoutBuilder`

### 🟠 Strava

- Sube la actividad automáticamente al finalizar
- Incluye en la descripción los valores de Peces T, Peces M y Total
- Refresca el token OAuth2 automáticamente antes de que expire
- La autenticación inicial se realiza desde el iPhone companion vía WatchConnectivity

### 📋 Historial de sesiones

- Guarda hasta 100 sesiones localmente con `UserDefaults`
- Estadísticas globales: total de sesiones, peces totales, media y récord 🏆
- Vista de detalle por sesión con comparativa T vs M y medallero del ganador
- Eliminar sesiones individualmente (swipe) o borrar todo

---

## 🖥 Pantallas

```
┌──────────────────────┐   ┌──────────────────────┐   ┌──────────────────────┐
│   🎣 Inicio          │   │   ⏱ Timer            │   │   🐟 Peces           │
│  ────────────────    │   │                      │   │                      │
│  [⏱ Tiempo][🆓 Libre]│   │ ● En curso · Temp.   │   │      00:45:23        │
│                      │   │                      │   │                      │
│  Duración            │ → │      00:45:23        │←→ │  🐟T  [−]  7  [+]   │
│  ┌──────────────┐    │   │                      │   │  ──────────────────  │
│  │   60 min  ↕  │    │   │  [🏁 Fin] [⏸ Pausa] │   │  🐟M  [−]  5  [+]   │
│  └──────────────┘    │   │                      │   │                      │
│                      │   │                      │   │                      │
│  [▶ Iniciar]         │   │                      │   │                      │
│  [🕐 Historial   5]  │   │                      │   │                      │
│  ● Strava conectado  │   │                      │   │                      │
└──────────────────────┘   └──────────────────────┘   └──────────────────────┘

┌──────────────────────┐   ┌──────────────────────────────────────┐
│  🏁 ¡Completado!     │   │  📋 Historial                        │
│  ──────────────────  │   │  ┌─────────────┬──────────────┐      │
│  ⏱ Duración   1h 00m │   │  │ Sesiones  5 │ Peces tot. 43│      │
│  🐟 Peces T       7  │   │  │ Media   8.6 │ Récord 🏆  14│      │
│  🐟 Peces M       5  │   │  └─────────────┴──────────────┘      │
│  📊 Total        12  │   │  13 Abr                   45m        │
│  ──────────────────  │   │  🐟 7  🐟 5          Total: 12       │
│  ♥ Apple Fitness  ✓  │   │  ──────────────────────────────────  │
│  ↑ Strava         ○  │   │  12 Abr                 1h 00m       │
│                      │   │  🐟 4  🐟 6          Total: 10       │
│  [Nueva sesión]      │   │                                      │
│  [🕐 Ver historial]  │   │  [🗑 Borrar todo]                    │
└──────────────────────┘   └──────────────────────────────────────┘

┌──────────────────────┐
│  🎣 Detalle          │
│  13 abr. 2026, 15:30 │
│  ──────────────────  │
│  ◉ Modo   ⏱ Temp.   │
│  ⏱ Duración  1h 00m  │
│  ──────────────────  │
│  🐟 Peces T       7  │
│  🐟 Peces M       5  │
│  Σ  Total        12  │
│  ──────────────────  │
│    [🐟 T lidera]     │
└──────────────────────┘
```

---

## 🏗 Arquitectura

```
NatureFlyFishingCompetition Watch App/
├── NatureFlyFishingCompetitionApp.swift   # Entry point @main
├── ContentView.swift                       # Router de estados (idle/running/finished)
│
├── Models/
│   ├── WorkoutSession.swift               # Modelo de sesión (Codable + Identifiable)
│   └── WorkoutHistoryStore.swift          # Persistencia local con UserDefaults
│
├── ViewModels/
│   └── WorkoutViewModel.swift             # Lógica central: timer, contadores, sync
│
├── Services/
│   ├── HealthKitService.swift             # HKWorkoutSession + HKLiveWorkoutBuilder
│   └── StravaService.swift                # OAuth2 token refresh + REST API
│
└── Views/
    ├── SetupView.swift                    # Selector de modo/duración + acceso historial
    ├── WorkoutView.swift                  # TabView deslizable durante el entrenamiento
    ├── TimerPageView.swift                # Cuenta atrás/tiempo + controles
    ├── CountersPageView.swift             # Contadores T y M
    ├── SummaryView.swift                  # Resumen post-sesión + estado sync
    ├── HistoryView.swift                  # Lista de sesiones + estadísticas
    └── HistoryDetailView.swift            # Detalle de sesión individual
```

**Patrón:** MVVM — `@StateObject` / `@EnvironmentObject` / `@ObservedObject` / `@MainActor`

---

## ⚙️ Requisitos

| Requisito | Versión |
|---|---|
| watchOS | 9.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| Cuenta Apple Developer | Necesaria para HealthKit en dispositivo real |
| Cuenta Strava API | Necesaria para sincronización con Strava |

---

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/srg1995/NatureFlyFishingCompetition.git
cd NatureFlyFishingCompetition
```

### 2. Generar el proyecto Xcode

El proyecto usa [XcodeGen](https://github.com/yonaskolb/XcodeGen). Si no lo tienes:

```bash
brew install xcodegen
xcodegen generate
```

### 3. Abrir en Xcode

```bash
open NatureFlyFishingCompetition.xcodeproj
```

### 4. Configurar Signing

En el target `NatureFlyFishingCompetition Watch App`:
- **Signing & Capabilities** → selecciona tu Team
- Activa la capability **HealthKit**

---

## 🔐 Configuración de Strava

### Crear la app en Strava

1. Ve a [strava.com/settings/api](https://www.strava.com/settings/api)
2. Crea una nueva aplicación
3. Copia el **Client ID** y el **Client Secret**

### Configurar credenciales

Abre `Services/StravaService.swift` y rellena:

```swift
private let clientID     = "TU_CLIENT_ID"
private let clientSecret = "TU_CLIENT_SECRET"
```

### Flujo OAuth en watchOS

El Apple Watch no tiene navegador web. El flujo de autenticación es:

1. La app companion del **iPhone** realiza el OAuth2 con Strava
2. Los tokens se envían al Watch vía **WatchConnectivity** (`WCSession`)
3. El Watch llama a:

```swift
stravaService.storeTokens(
    accessToken:  "...",
    refreshToken: "...",
    expiresAt:    timestamp
)
```

4. A partir de ese momento el Watch sube las actividades y renueva el token automáticamente

---

## 🎨 Diseño

- Fondo negro nativo del OLED del Apple Watch
- **Peces T** → 🔴 rojo en todas las vistas
- **Peces M** → 🔵 azul en todas las vistas
- Botones grandes optimizados para uso con guantes o en exteriores
- Timer cambia de color según el tiempo restante:
  - `> 50%` restante → 🟢 verde
  - `20–50%` restante → 🟡 amarillo
  - `< 20%` restante → 🔴 rojo

---

## 📄 Licencia

MIT License — libre para uso personal y comercial.
