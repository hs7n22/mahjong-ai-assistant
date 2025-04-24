import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://ftsbqrndremksnpcdbbl.supabase.co';
const supabaseAnoKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0c2Jxcm5kcmVta3NucGNkYmJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMDMxNjEsImV4cCI6MjA2MDg3OTE2MX0.zhKxbX78IctgxEp2tDD2g8uygomYyjkRsCeIxlsjO98';

Future<void> initSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnoKey);
}
