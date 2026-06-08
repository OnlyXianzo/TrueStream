//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <flutter_angle/flutter_angle_plugin.h>
#include <rive_native/rive_native_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  FlutterAnglePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterAnglePlugin"));
  RiveNativePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("RiveNativePlugin"));
}
