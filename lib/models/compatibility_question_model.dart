class CompatibilityQuestion {
  final String id;
  final String question;
  final String category;
  final List<CompatibilityOption> options;
  final bool isRequired;

  CompatibilityQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.options,
    this.isRequired = true,
  });

  factory CompatibilityQuestion.fromJson(Map<String, dynamic> json) {
    return CompatibilityQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      category: json['category'] as String,
      options: (json['options'] as List)
          .map((opt) =>
              CompatibilityOption.fromJson(opt as Map<String, dynamic>))
          .toList(),
      isRequired: json['is_required'] as bool? ?? true,
    );
  }
}

class CompatibilityOption {
  final String id;
  final String label;
  final String value;
  final String? icon;

  CompatibilityOption({
    required this.id,
    required this.label,
    required this.value,
    this.icon,
  });

  factory CompatibilityOption.fromJson(Map<String, dynamic> json) {
    return CompatibilityOption(
      id: json['id'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      icon: json['icon'] as String?,
    );
  }
}

// Preguntas predefinidas del cuestionario
class CompatibilityQuestions {
  static List<CompatibilityQuestion> getDefaultQuestions() {
    return [
      CompatibilityQuestion(
        id: 'schedule',
        question: '¿Cuál es tu horario habitual?',
        category: 'horarios',
        options: [
          CompatibilityOption(
              id: '1',
              label: 'Madrugador (5-9 AM)',
              value: 'early_bird',
              icon: '🌅'),
          CompatibilityOption(
              id: '2', label: 'Diurno (9 AM - 6 PM)', value: 'day', icon: '☀️'),
          CompatibilityOption(
              id: '3',
              label: 'Nocturno (6 PM - 12 AM)',
              value: 'night',
              icon: '🌙'),
          CompatibilityOption(
              id: '4', label: 'Flexible', value: 'flexible', icon: '🔄'),
        ],
      ),
      CompatibilityQuestion(
        id: 'pets',
        question: '¿Aceptas mascotas?',
        category: 'mascotas',
        options: [
          CompatibilityOption(
              id: '1', label: 'Sí, me encantan', value: 'yes', icon: '🐕'),
          CompatibilityOption(
              id: '2',
              label: 'No, prefiero sin mascotas',
              value: 'no',
              icon: '❌'),
          CompatibilityOption(
              id: '3', label: 'Depende del tipo', value: 'depends', icon: '🤔'),
        ],
      ),
      CompatibilityQuestion(
        id: 'smoking',
        question: '¿Aceptas que se fume en el departamento?',
        category: 'humo',
        options: [
          CompatibilityOption(
              id: '1', label: 'Sí, no me molesta', value: 'yes', icon: '🚬'),
          CompatibilityOption(
              id: '2', label: 'No, prefiero sin humo', value: 'no', icon: '🚭'),
          CompatibilityOption(
              id: '3',
              label: 'Solo en áreas exteriores',
              value: 'outside',
              icon: '🌳'),
        ],
      ),
      CompatibilityQuestion(
        id: 'parties',
        question: '¿Qué tan frecuentes son tus fiestas/reuniones?',
        category: 'fiestas',
        options: [
          CompatibilityOption(
              id: '1',
              label: 'Muy frecuentes',
              value: 'very_often',
              icon: '🎉'),
          CompatibilityOption(
              id: '2', label: 'Ocasionales', value: 'occasional', icon: '🎊'),
          CompatibilityOption(
              id: '3', label: 'Raras veces', value: 'rare', icon: '🤫'),
          CompatibilityOption(
              id: '4', label: 'Nunca', value: 'never', icon: '🔇'),
        ],
      ),
      CompatibilityQuestion(
        id: 'cleaning',
        question: '¿Qué tan importante es la limpieza para ti?',
        category: 'limpieza',
        options: [
          CompatibilityOption(
              id: '1',
              label: 'Muy importante (limpieza diaria)',
              value: 'very_important',
              icon: '✨'),
          CompatibilityOption(
              id: '2',
              label: 'Importante (limpieza semanal)',
              value: 'important',
              icon: '🧹'),
          CompatibilityOption(
              id: '3',
              label: 'Relajado (limpieza ocasional)',
              value: 'relaxed',
              icon: '😌'),
        ],
      ),
      CompatibilityQuestion(
        id: 'laundry',
        question: '¿Cómo manejas la lavandería?',
        category: 'limpieza',
        options: [
          CompatibilityOption(
              id: '1', label: 'Lavo mi propia ropa', value: 'own', icon: '👕'),
          CompatibilityOption(
              id: '2',
              label: 'Lavandería compartida',
              value: 'shared',
              icon: '👔'),
          CompatibilityOption(
              id: '3',
              label: 'Servicio externo',
              value: 'external',
              icon: '🏪'),
        ],
      ),
      CompatibilityQuestion(
        id: 'alcohol',
        question: '¿Aceptas consumo de alcohol en el departamento?',
        category: 'fiestas',
        options: [
          CompatibilityOption(
              id: '1', label: 'Sí, no hay problema', value: 'yes', icon: '🍷'),
          CompatibilityOption(
              id: '2',
              label: 'Solo ocasionalmente',
              value: 'occasional',
              icon: '🥂'),
          CompatibilityOption(
              id: '3',
              label: 'No, prefiero sin alcohol',
              value: 'no',
              icon: '🚫'),
        ],
      ),
    ];
  }
}
