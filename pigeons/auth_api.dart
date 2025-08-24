import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class AuthApi {
  String getPlatformVersion();
}
