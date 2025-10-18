import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/services/storage_service.dart';
import 'package:mealtime/models/cat_model.dart';
import 'package:mealtime/widgets/cat_photo_picker.dart';
import 'package:mealtime/widgets/schedule_config_widget.dart';

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({super.key});

  @override
  State<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _weightController = TextEditingController();
  final _dietaryRestrictionsController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _groupsController = TextEditingController();

  File? _selectedImage;
  DateTime? _selectedBirthdate;
  double? _currentWeight;
  List<String> _groups = [];
  FeedingSchedule _schedule = FeedingSchedule(
    type: ScheduleType.fixedInterval,
    intervalHours: 8,
    isActive: true,
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _weightController.dispose();
    _dietaryRestrictionsController.dispose();
    _medicalNotesController.dispose();
    _groupsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Gato'),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveCat,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo section
              _buildPhotoSection(),
              const SizedBox(height: 24),

              // Basic info section
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // Health info section
              _buildHealthInfoSection(),
              const SizedBox(height: 24),

              // Groups section
              _buildGroupsSection(),
              const SizedBox(height: 24),

              // Schedule section
              _buildScheduleSection(),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveCat,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Adicionar Gato'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto do Gato',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: CatPhotoPicker(
                selectedImage: _selectedImage,
                onImageSelected: (image) {
                  setState(() {
                    _selectedImage = image;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações Básicas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Gato *',
                hintText: 'Ex: Mimi, Garfield, Luna',
                prefixIcon: Icon(Icons.pets),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                if (value.trim().length < 2) {
                  return 'Nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Birthdate
            TextFormField(
              controller: _birthdateController,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
                hintText: 'DD/MM/AAAA',
                prefixIcon: Icon(Icons.cake),
              ),
              readOnly: true,
              onTap: () => _selectBirthdate(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Saúde',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Current weight
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso Atual (kg)',
                hintText: 'Ex: 4.5',
                prefixIcon: Icon(Icons.monitor_weight),
                suffixText: 'kg',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                _currentWeight = double.tryParse(value);
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Peso deve ser um número válido';
                  }
                  if (weight > 50) {
                    return 'Peso muito alto para um gato';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Dietary restrictions
            TextFormField(
              controller: _dietaryRestrictionsController,
              decoration: const InputDecoration(
                labelText: 'Restrições Alimentares',
                hintText: 'Ex: Sem grãos, apenas ração úmida',
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Medical notes
            TextFormField(
              controller: _medicalNotesController,
              decoration: const InputDecoration(
                labelText: 'Notas Médicas',
                hintText: 'Ex: Diabetes, alergias, medicações',
                prefixIcon: Icon(Icons.medical_services),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grupos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Organize seus gatos em grupos (ex: filhotes, idosos, especiais)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            
            // Groups input
            TextFormField(
              controller: _groupsController,
              decoration: const InputDecoration(
                labelText: 'Adicionar Grupo',
                hintText: 'Ex: filhotes, idosos, especiais',
                prefixIcon: Icon(Icons.group),
                suffixIcon: Icon(Icons.add),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (value) {
                if (value.trim().isNotEmpty && !_groups.contains(value.trim())) {
                  setState(() {
                    _groups.add(value.trim());
                    _groupsController.clear();
                  });
                }
              },
            ),
            
            // Groups list
            if (_groups.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _groups.map((group) {
                  return Chip(
                    label: Text(group),
                    onDeleted: () {
                      setState(() {
                        _groups.remove(group);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horário de Alimentação',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ScheduleConfigWidget(
              schedule: _schedule,
              onScheduleChanged: (schedule) {
                setState(() {
                  _schedule = schedule;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthdate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedBirthdate = date;
        _birthdateController.text = '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      });
    }
  }

  Future<void> _saveCat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final household = context.read<HouseholdProvider>().currentHousehold;
      if (household == null) {
        throw Exception('Nenhuma casa selecionada');
      }

      final databaseService = DatabaseService(uid: user.uid);
      String? photoUrl;

      // Upload photo if selected
      if (_selectedImage != null) {
        final storageService = StorageService();
        photoUrl = await storageService.uploadCatPhoto(household.id, 'temp', _selectedImage!);
      }

      // Prepare cat data
      final catData = {
        'name': _nameController.text.trim(),
        'photoUrl': photoUrl,
        'birthdate': _selectedBirthdate?.toIso8601String(),
        'currentWeight': _currentWeight,
        'dietaryRestrictions': _dietaryRestrictionsController.text.trim().isEmpty
            ? null
            : _dietaryRestrictionsController.text.trim(),
        'medicalNotes': _medicalNotesController.text.trim().isEmpty
            ? null
            : _medicalNotesController.text.trim(),
        'groups': _groups.isEmpty ? null : _groups,
        'schedule': _schedule.toMap(),
      };

      await databaseService.addCat(household.id, catData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} foi adicionado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar gato: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
