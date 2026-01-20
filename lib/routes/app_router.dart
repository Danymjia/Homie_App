import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomie_app/screens/auth/login_screen.dart';
import 'package:roomie_app/screens/auth/register_screen.dart';
import 'package:roomie_app/screens/auth/register_screen_v2.dart';
import 'package:roomie_app/screens/auth/forgot_password_screen.dart';
import 'package:roomie_app/screens/compatibility/compatibility_questionnaire_screen.dart';
import 'package:roomie_app/screens/map/map_screen_v2.dart';
import 'package:roomie_app/screens/security/report_screen.dart';
import 'package:roomie_app/screens/home/swipe_cards_screen.dart';
import 'package:roomie_app/screens/chat/chat_list_screen.dart';
import 'package:roomie_app/screens/chat/chat_detail_screen.dart';
import 'package:roomie_app/screens/profile/profile_screen.dart';
import 'package:roomie_app/screens/profile/register_apartment_screen.dart';
import 'package:roomie_app/screens/match/match_screen.dart';
import 'package:roomie_app/screens/premium/premium_features_screen.dart';
import 'package:roomie_app/screens/premium/premium_plans_screen.dart';
import 'package:roomie_app/screens/premium/who_liked_me_screen.dart';
import 'package:roomie_app/screens/premium/custom_themes_screen.dart';
import 'package:roomie_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/forgot-password';
      
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }
      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreenV2(),
      ),
      GoRoute(
        path: '/compatibility-questionnaire',
        builder: (context, state) => const CompatibilityQuestionnaireScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const SwipeCardsScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreenV2(),
      ),
      GoRoute(
        path: '/report/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final apartmentId = state.uri.queryParameters['apartmentId'];
          return ReportScreen(
            reportedUserId: userId,
            apartmentId: apartmentId,
          );
        },
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatDetailScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/register-apartment',
        builder: (context, state) => const RegisterApartmentScreen(),
      ),
      GoRoute(
        path: '/match/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return MatchScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/premium/features',
        builder: (context, state) => const PremiumFeaturesScreen(),
      ),
      GoRoute(
        path: '/premium/plans',
        builder: (context, state) => const PremiumPlansScreen(),
      ),
      GoRoute(
        path: '/premium/likes',
        builder: (context, state) => const WhoLikedMeScreen(),
      ),
      GoRoute(
        path: '/premium/themes',
        builder: (context, state) => const CustomThemesScreen(),
      ),
    ],
  );
}
