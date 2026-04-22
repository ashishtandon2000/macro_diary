

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// NOTE: Single instance of http client is preferred because: When you use a single instance, the client maintains a "pool" of active connections to the server.

final httpClientProvider = Provider((ref) => http.Client());