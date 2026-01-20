import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40.0,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 50.0,
  });

  // Generar iniciales para mostrar cuando no hay foto
  String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // Generar color basado en el nombre
  Color generateColorFromName(String name) {
    final hash = name.hashCode;
    final hue = hash.abs() % 360;
    return HSLColor.fromAHSL(0.7, hue.toDouble(), 0.6, 0.5).toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Si hay una URL de imagen válida, mostrarla
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        !imageUrl!.contains('placeholder')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildDefaultAvatar(),
          errorWidget: (context, url, error) => _buildDefaultAvatar(),
        ),
      );
    }

    // Si no hay imagen, mostrar avatar por defecto
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? generateColorFromName(name),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: name.isNotEmpty
            ? Text(
                getInitials(name),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : FaIcon(
                FontAwesomeIcons.circleUser,
                color: iconColor ?? Colors.white.withOpacity(0.7),
                size: size * 0.7,
              ),
      ),
    );
  }
}

// Widget específico para iconos de perfil con diferentes estilos
class ProfileIconAvatar extends StatelessWidget {
  final double size;
  final ProfileIconStyle style;
  final Color? color;

  const ProfileIconAvatar({
    super.key,
    this.size = 40.0,
    this.style = ProfileIconStyle.circle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ProfileIconStyle.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFE57373),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: size * 0.6,
          ),
        );

      case ProfileIconStyle.rounded:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFE57373),
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: size * 0.6,
          ),
        );

      case ProfileIconStyle.faUser:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFE57373),
            shape: BoxShape.circle,
          ),
          child: FaIcon(
            FontAwesomeIcons.user,
            color: Colors.white,
            size: size * 0.5,
          ),
        );

      case ProfileIconStyle.faUserCircle:
        return FaIcon(
          FontAwesomeIcons.circleUser,
          color: color ?? const Color(0xFFE57373),
          size: size,
        );

      case ProfileIconStyle.faUserAstronaut:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFE57373),
            shape: BoxShape.circle,
          ),
          child: FaIcon(
            FontAwesomeIcons.userAstronaut,
            color: Colors.white,
            size: size * 0.5,
          ),
        );
    }
  }
}

enum ProfileIconStyle {
  circle,
  rounded,
  faUser,
  faUserCircle,
  faUserAstronaut,
}
