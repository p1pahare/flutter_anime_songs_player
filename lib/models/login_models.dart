// To parse this JSON data, do
//
//     final me = meFromJson(jsonString);

import 'dart:convert';

Me meFromJson(String str) => Me.fromJson(json.decode(str));

String meToJson(Me data) => json.encode(data.toJson());

class Me {
    User user;

    Me({
        required this.user,
    });

    factory Me.fromJson(Map<String, dynamic> json) => Me(
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
    };
}

class User {
    int id;
    String name;
    String email;
    DateTime emailVerifiedAt;
    dynamic twoFactorConfirmedAt;
    List<dynamic> permissions;
    List<Role> roles;

    User({
        required this.id,
        required this.name,
        required this.email,
        required this.emailVerifiedAt,
        required this.twoFactorConfirmedAt,
        required this.permissions,
        required this.roles,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: DateTime.parse(json["email_verified_at"]),
        twoFactorConfirmedAt: json["two_factor_confirmed_at"],
        permissions: List<dynamic>.from(json["permissions"].map((x) => x)),
        roles: List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt.toIso8601String(),
        "two_factor_confirmed_at": twoFactorConfirmedAt,
        "permissions": List<dynamic>.from(permissions.map((x) => x)),
        "roles": List<dynamic>.from(roles.map((x) => x.toJson())),
    };
}

class Role {
    int id;
    String name;
    String guardName;
    bool roleDefault;
    dynamic color;
    dynamic priority;

    Role({
        required this.id,
        required this.name,
        required this.guardName,
        required this.roleDefault,
        required this.color,
        required this.priority,
    });

    factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        guardName: json["guard_name"],
        roleDefault: json["default"],
        color: json["color"],
        priority: json["priority"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "guard_name": guardName,
        "default": roleDefault,
        "color": color,
        "priority": priority,
    };
}
