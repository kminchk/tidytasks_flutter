# tidytasks_v1

lib/
├── main.dart
├── constants/
│   └── supabase_keys.dart       // สำหรับเก็บ URL และ anon key
├── screens/
│   ├── welcome_screen.dart      // หน้าแรก
│   ├── login_screen.dart        // Login แบบ email/password
│   ├── register_screen.dart     // Register แบบ email/password
│   ├── home_screen.dart         // หน้า to-do list
│   ├── profile_screen.dart      // หน้าโปรไฟล์
├── widgets/
│   └── task_tile.dart           // รายการ to-do list
└── services/
    └── auth_service.dart        // จัดการ auth เช่น login/logout/google
