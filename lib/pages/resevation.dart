/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HotelReservationPage extends StatefulWidget {
  final Map<String, dynamic> hotel;

  final String? userName;
  final String? userPhone;
  final String? userEmail;

  const HotelReservationPage({
    super.key,
    required this.hotel,
    this.userName,
    this.userPhone,
    this.userEmail,
  });

  @override
  State<HotelReservationPage> createState() => _HotelReservationPageState();
}

class _HotelReservationPageState extends State<HotelReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _quantity = 1;
  bool _isLoading = false;

  // Correction: utiliser la méthode initState() pour pré-remplir les champs
  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      _nameController.text = widget.userName!;
    }
    if (widget.userPhone != null) {
      _phoneController.text = widget.userPhone!;
    }
    if (widget.userEmail != null) {
      _emailController.text = widget.userEmail!;
    }
  }

  int get _pricePerNight {
    return int.tryParse(widget.hotel['price'].toString()) ?? 0;
  }

  int get _totalNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  int get _totalPrice {
    return _pricePerNight * _quantity * (_totalNights == 0 ? 1 : _totalNights);
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && !_checkInDate!.isBefore(_checkOutDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _submitReservation() {
    if (!_formKey.currentState!.validate()) return;
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les dates de séjour'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_checkInDate!.isBefore(_checkOutDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de départ doit être après la date d\'arrivée'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      _showConfirmationDialog();
    });
  }

  void _showConfirmationDialog() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Réservation confirmée'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Merci ${_nameController.text} !'),
              const SizedBox(height: 10),
              Text(
                  'Votre réservation à ${widget.hotel['name']} a bien été enregistrée.'),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 10),
              _buildReservationDetailRow('Type de chambre:',
                  widget.hotel['room'] ?? 'Chambre Standard'),
              _buildReservationDetailRow(
                  'Dates:', '${dateFormat.format(_checkInDate!)} - ${dateFormat.format(_checkOutDate!)}'),
              _buildReservationDetailRow('Durée:', '$_totalNights nuits'),
              _buildReservationDetailRow('Nombre de chambres:', '$_quantity'),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _buildReservationDetailRow(
                  'Total:', '$_totalPrice F', isBold: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Retour à l\'accueil'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetailRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : 'Sélectionner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: date != null ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre de chambres',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver à ${widget.hotel['name']}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotel['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Text(widget.hotel['location']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.hotel['price']} F / nuit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Vos informations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre nom' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? 'Entrez un numéro de téléphone' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (facultatif)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text(
                'Dates de séjour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildDateSelector(
                    "Date d'arrivée",
                    _checkInDate,
                        () => _selectDate(context, true),
                  ),
                  const SizedBox(width: 10),
                  _buildDateSelector(
                    "Date de départ",
                    _checkOutDate,
                        () => _selectDate(context, false),
                  ),
                ],
              ),
              if (_checkInDate != null && _checkOutDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Durée du séjour: $_totalNights nuits',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _buildQuantitySelector(),
              const SizedBox(height: 20),
              const Text(
                'Notes supplémentaires (facultatif)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Demandes spéciales, remarques...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_checkInDate != null && _checkOutDate != null)
                      _buildPriceDetailRow(
                        '${widget.hotel['price']} F x $_quantity chambre(s) x $_totalNights nuits',
                        '${_pricePerNight * _quantity * _totalNights} F',
                      ),
                    if (_checkInDate == null || _checkOutDate == null)
                      _buildPriceDetailRow(
                        '${widget.hotel['price']} F x $_quantity chambre(s) x 1 nuit',
                        '${_pricePerNight * _quantity} F',
                      ),
                    const Divider(height: 20),
                    _buildPriceDetailRow(
                      'Total',
                      '$_totalPrice F',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitReservation,
                child: const Text(
                  'CONFIRMER LA RÉSERVATION',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}*/




/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HotelReservationPage extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const HotelReservationPage({super.key, required this.hotel});

  @override
  State<HotelReservationPage> createState() => _HotelReservationPageState();
}

class _HotelReservationPageState extends State<HotelReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _quantity = 1;
  bool _isLoading = false;

  int get _pricePerNight {
    return int.tryParse(widget.hotel['price'].toString()) ?? 0;
  }

  int get _totalNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  int get _totalPrice {
    return _pricePerNight * _quantity * (_totalNights == 0 ? 1 : _totalNights);
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent, // Couleur principale
              onPrimary: Colors.white, // Couleur du texte sur la couleur principale
              surface: Colors.white, // Couleur de l'arrière-plan
              onSurface: Colors.black, // Couleur du texte sur l'arrière-plan
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!, // Utiliser l'enfant directement
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _submitReservation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulation de l'envoi des données
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation confirmée avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Réservation - ${widget.hotel['name'] ?? 'Hôtel inconnu'}"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informations de la réservation',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom et Prénom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Adresse email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes supplémentaires (facultatif)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Dates',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date d\'arrivée',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _checkInDate != null ? DateFormat('dd/MM/yyyy').format(_checkInDate!) : 'Sélectionner une date',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de départ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _checkOutDate != null ? DateFormat('dd/MM/yyyy').format(_checkOutDate!) : 'Sélectionner une date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Détails de la réservation',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nombre de chambres', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPriceDetailRow('Prix par nuit', '${_pricePerNight.toString()} FCFA'),
              _buildPriceDetailRow('Nombre de nuits', _totalNights.toString()),
              const Divider(),
              _buildPriceDetailRow('Total', '${_totalPrice.toString()} FCFA', isTotal: true),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitReservation,
                child: const Text(
                  'CONFIRMER LA RÉSERVATION',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}*/






import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api_reservationService.dart'; // Assurez-vous que le chemin est correct

class HotelReservationPage extends StatefulWidget {
  final Map<String, dynamic> hotel;
  final String? userName;
  final String? userPhone;
  final String? userEmail;

  const HotelReservationPage({
    super.key,
    required this.hotel,
    this.userName,
    this.userPhone,
    this.userEmail,
  });

  @override
  State<HotelReservationPage> createState() => _HotelReservationPageState();
}

class _HotelReservationPageState extends State<HotelReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _quantity = 1;
  bool _isLoading = false;

  final _reservationService = ReservationService(); // Instance du service

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      _nameController.text = widget.userName!;
    }
    if (widget.userPhone != null) {
      _phoneController.text = widget.userPhone!;
    }
    if (widget.userEmail != null) {
      _emailController.text = widget.userEmail!;
    }
  }

  int get _pricePerNight {
    return int.tryParse(widget.hotel['price'].toString()) ?? 0;
  }

  int get _totalNights {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    return _checkOutDate!.difference(_checkInDate!).inDays;
  }

  int get _totalPrice {
    return _pricePerNight * _quantity * (_totalNights == 0 ? 1 : _totalNights);
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && !_checkInDate!.isBefore(_checkOutDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les dates de séjour'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_checkInDate!.isBefore(_checkOutDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de départ doit être après la date d\'arrivée'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final reservationData = {
      'hotel_name': widget.hotel['name'],
      'user_name': _nameController.text,
      'user_phone': _phoneController.text,
      'user_email': _emailController.text,
      'check_in_date': _checkInDate!.toIso8601String(),
      'check_out_date': _checkOutDate!.toIso8601String(),
      'quantity': _quantity,
      'total_price': _totalPrice,
      'notes': _notesController.text,
    };

    try {
      final response = await _reservationService.addReservation(reservationData);
      print('Réponse de l\'API: $response'); // Pour le débogage

      setState(() => _isLoading = false);
      _showConfirmationDialog();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de réservation: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      print('Erreur lors de la réservation: $e');
    }
  }

  void _showConfirmationDialog() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Réservation confirmée'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Merci ${_nameController.text} !'),
              const SizedBox(height: 10),
              Text(
                  'Votre réservation à ${widget.hotel['name']} a bien été enregistrée.'),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 10),
              _buildReservationDetailRow('Type de chambre:',
                  widget.hotel['room'] ?? 'Chambre Standard'),
              _buildReservationDetailRow(
                  'Dates:', '${dateFormat.format(_checkInDate!)} - ${dateFormat.format(_checkOutDate!)}'),
              _buildReservationDetailRow('Durée:', '$_totalNights nuits'),
              _buildReservationDetailRow('Nombre de chambres:', '$_quantity'),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _buildReservationDetailRow(
                  'Total:', '$_totalPrice F', isBold: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Retour à l\'accueil'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetailRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : 'Sélectionner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: date != null ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre de chambres',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver à ${widget.hotel['name']}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotel['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Text(widget.hotel['location']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.hotel['price']} F / nuit',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Vos informations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre nom' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? 'Entrez un numéro de téléphone' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (facultatif)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text(
                'Dates de séjour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildDateSelector(
                    "Date d'arrivée",
                    _checkInDate,
                        () => _selectDate(context, true),
                  ),
                  const SizedBox(width: 10),
                  _buildDateSelector(
                    "Date de départ",
                    _checkOutDate,
                        () => _selectDate(context, false),
                  ),
                ],
              ),
              if (_checkInDate != null && _checkOutDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Durée du séjour: $_totalNights nuits',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _buildQuantitySelector(),
              const SizedBox(height: 20),
              const Text(
                'Notes supplémentaires (facultatif)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Demandes spéciales, remarques...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_checkInDate != null && _checkOutDate != null)
                      _buildPriceDetailRow(
                        '${widget.hotel['price']} F x $_quantity chambre(s) x $_totalNights nuits',
                        '${_pricePerNight * _quantity * _totalNights} F',
                      ),
                    if (_checkInDate == null || _checkOutDate == null)
                      _buildPriceDetailRow(
                        '${widget.hotel['price']} F x $_quantity chambre(s) x 1 nuit',
                        '${_pricePerNight * _quantity} F',
                      ),
                    const Divider(height: 20),
                    _buildPriceDetailRow(
                      'Total',
                      '$_totalPrice F',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitReservation,
                child: const Text(
                  'CONFIRMER LA RÉSERVATION',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}