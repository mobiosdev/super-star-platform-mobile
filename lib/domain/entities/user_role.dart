enum UserRole {
  superadmin,
  admin,
  superstar,
  customer;

  String get displayName {
    switch (this) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superstar:
        return 'Superstar';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get homeRoute {
    switch (this) {
      case UserRole.superadmin:
        return '/superadmin';
      case UserRole.admin:
        return '/admin';
      case UserRole.superstar:
        return '/creator';
      case UserRole.customer:
        return '/customer';
    }
  }
}
