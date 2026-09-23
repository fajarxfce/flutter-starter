import 'package:dio/dio.dart';

void disposeDio(Dio dio) => dio.close(force: true);
