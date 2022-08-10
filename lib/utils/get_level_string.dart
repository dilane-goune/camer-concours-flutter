import 'dart:io';

String getLevelString(String key) {
  final local = Platform.localeName;

  if (local.startsWith('en')) {
    switch (key) {
      case 'L1':
        return 'Year one';
      case 'L2':
        return 'Year two';
      case 'L3':
        return 'Year three';
      case 'L4':
        return 'Year four';
      case 'L5':
        return 'Year five';
      default:
        return 'Unknown';
    }
  } else {
    switch (key) {
      case 'L1':
        return 'Prémiere année';
      case 'L2':
        return 'Deuxieme année';
      case 'L3':
        return 'Troisieme année';
      case 'L4':
        return 'Quatrieme année';
      case 'L5':
        return 'Cinqieme année';
      default:
        return 'Inconnu';
    }
  }
}
