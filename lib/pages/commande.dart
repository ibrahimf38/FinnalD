import 'package:MaliDiscover/api/api_commandeService.dart';
import 'package:flutter/material.dart';import 'package:flutter/material.dart';
import 'package:MaliDiscover/api/api_service.dart';// Assurez-vous d'importer ApiService si nécessaire pour l'initialisation du service

class RestaurantOrderPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final String? userName;
  final String? userPhone;
  final String? userEmail;
  // TODO: Ajoutez ici l'ID du gestionnaire ou passez-le dans les arguments
  final String? idGestionnaire;

  const RestaurantOrderPage({
    super.key,
    required this.restaurant,
    this.userName,
    this.userPhone,
    this.userEmail,
    // Note: 'id_gestionnaire' n'est pas fourni dans les props, c'est un point à revoir
    this.idGestionnaire = "ID_DEFAULT_GESTIONNAIRE", // À remplacer par le vrai ID
  });

  @override
  State<RestaurantOrderPage> createState() => _RestaurantOrderPageState();
}

class _RestaurantOrderPageState extends State<RestaurantOrderPage> {
  final _formKey = GlobalKey<FormState>();
  // 2. Initialisation du service
  final CommandeService _commandeService = CommandeService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      nameController.text = widget.userName!;
    }
    if (widget.userPhone != null) {
      phoneController.text = widget.userPhone!;
    }
    // L'adresse pourrait aussi être pré-remplie si disponible
  }

  // Assurez-vous d'éliminer les contrôleurs
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    notesController.dispose();
    addressController.dispose();
    super.dispose();
  }

  int get totalPrice {
    int price = int.tryParse(widget.restaurant['price'].toString()) ?? 0;
    int quantity = int.tryParse(widget.restaurant['quantity'].toString()) ?? 0;
    return price * quantity;
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (totalPrice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un plat.")),
      );
      return;
    }
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une heure de livraison.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // 3. Créer le Map de données pour l'API (s'assurer de la cohérence avec CommandeController.js)
    final commandeData = {
      // Les champs requis par CommandeController.js
      'id_restaurant': widget.restaurant['id_restaurant'], // Doit correspondre à la clé du backend
      'id_gestionnaire': widget.idGestionnaire, // ID du gestionnaire
      'qte_commande': int.tryParse(widget.restaurant['quantity'].toString()) ?? 0, // Quantité totale commandée

      // Données supplémentaires pour le contexte de la commande
      'clientName': nameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'total': totalPrice,
      'time': selectedTime!.format(context),
      'notes': notesController.text,
      'plat_name': widget.restaurant['plat'], // Nom du plat
      'price_per_unit': widget.restaurant['price'], // Prix unitaire

      // date_commande sera générée par le backend si non fournie
      // 'date_commande': DateTime.now().toIso8601String(), // Optionnel
    };

    try {
      // 4. Appel à l'API pour ajouter la commande
      final response = await _commandeService.addCommande(commandeData);
      print('Response API: $response');

      if (!mounted) return;

      // Créer l'objet à retourner à la page précédente
      final commandeResult = {
        ...commandeData,
        'id_commande': response['id_commande'],
      };

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Commande envoyée'),
          content: Text('Votre commande a été prise en compte. ID: ${response['id_commande']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fermer dialog
                Navigator.pop(context, commandeResult); // renvoyer la commande
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de l'envoi de la commande: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... Reste du code de build ...
    return Scaffold(
      appBar: AppBar(
        title: Text("Commander chez ${widget.restaurant['nom']}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Informations client", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Votre nom",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Entrez votre nom" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Téléphone",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? "Entrez un numéro valide" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Adresse de livraison",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Entrez une adresse" : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(selectedTime == null
                                ? "Choisissez une heure de livraison"
                                : "Heure : ${selectedTime!.format(context)}"),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time),
                            label: const Text("Choisir"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.restaurant['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(widget.restaurant['plat']),
                  subtitle: Text("${widget.restaurant['price']} FCFA"),
                  trailing: QuantitySelector(
                    quantity: int.tryParse(widget.restaurant['quantity'].toString()) ?? 0,
                    onChanged: (q) => setState(() => widget.restaurant['quantity'] = q.toString()),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: "Notes spéciales",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total :", style: TextStyle(fontSize: 18)),
                          Text(
                            "$totalPrice FCFA",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitOrder,
                        icon: _isSubmitting
                            ? const SizedBox(
                            width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                            : const Icon(Icons.check),
                        label: Text(_isSubmitting ? "Traitement..." : "Confirmer la commande"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;

  const QuantitySelector({super.key, required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
        ),
        Text('$quantity', style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}
/*
import 'package:flutter/material.dart';

class RestaurantOrderPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantOrderPage({super.key, required this.restaurant});

  @override
  State<RestaurantOrderPage> createState() => _RestaurantOrderPageState();
}

class _RestaurantOrderPageState extends State<RestaurantOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  int get totalPrice {
    int price = int.tryParse(widget.restaurant['price'].toString()) ?? 0;
    int quantity = int.tryParse(widget.restaurant['quantity'].toString()) ?? 0;
    return price * quantity;
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (totalPrice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un plat.")),
      );
      return;
    }
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une heure de livraison.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1)); // Simulation

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Commande envoyée'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              Text(
                'Merci ${nameController.text} !',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Votre commande de $totalPrice FCFA a été prise en compte.'),
              const SizedBox(height: 10),
              Text('Livraison à : ${addressController.text}'),
              const SizedBox(height: 5),
              Text('Heure souhaitée : ${selectedTime!.format(context)}'),
              if (notesController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Notes spéciales :'),
                Text(notesController.text,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Commander chez ${widget.restaurant['name']}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Infos client
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Informations client",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Votre nom",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        v!.isEmpty ? 'Entrez votre nom' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Téléphone",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                        v!.isEmpty ? 'Entrez un numéro valide' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Adresse de livraison",
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        v!.isEmpty ? 'Entrez une adresse' : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(selectedTime == null
                                  ? "Choisir heure"
                                  : selectedTime!.format(context)),
                              onPressed: _pickTime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Menu
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text("Votre commande",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),
                      ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.restaurant['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(widget.restaurant['plat'] ?? 'Plat principal'),
                        subtitle:
                        Text('${widget.restaurant['price'] ?? '0'} FCFA'),
                        trailing: QuantitySelector(
                          quantity: int.tryParse(
                              widget.restaurant['quantity'].toString()) ??
                              0,
                          onChanged: (q) =>
                              setState(() => widget.restaurant['quantity'] = q),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: "Notes spéciales (allergies, etc.)",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Total + bouton
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total :",
                              style: TextStyle(fontSize: 18)),
                          Text("$totalPrice FCFA",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitOrder,
                          icon: _isSubmitting
                              ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                              : const Icon(Icons.check),
                          label: Text(_isSubmitting
                              ? "Traitement..."
                              : "Confirmer la commande"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding:
                              const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// QuantitySelector reste inchangé
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;

  const QuantitySelector(
      {super.key, required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$quantity', style: const TextStyle(fontSize: 16)),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}
*/



/* import 'package:flutter/material.dart';

class RestaurantOrderPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantOrderPage({super.key, required this.restaurant});

  @override
  State<RestaurantOrderPage> createState() => _RestaurantOrderPageState();
}

class _RestaurantOrderPageState extends State<RestaurantOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  int get totalPrice {
    int price = int.tryParse(widget.restaurant['price'].toString()) ?? 0;
    int quantity = int.tryParse(widget.restaurant['quantity'].toString()) ?? 0;
    return price * quantity;
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (totalPrice == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un plat.")),
      );
      return;
    }
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir une heure de livraison.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulation

    if (!mounted) return;

    // 👉 Créer la commande
    final commande = {
      'restaurantId': widget.restaurant['id_restaurant'],
      'restaurantName': widget.restaurant['name'],
      'plat': widget.restaurant['plat'],
      'price': widget.restaurant['price'],
      'quantity': widget.restaurant['quantity'],
      'total': totalPrice,
      'clientName': nameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'time': selectedTime!.format(context),
      'notes': notesController.text,
    };

    // Afficher confirmation et retourner commande
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Commande envoyée'),
        content: const Text('Votre commande a été prise en compte.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fermer dialog
              Navigator.pop(context, commande); // 👉 renvoyer la commande
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Commander chez ${widget.restaurant['nom']}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Infos client
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Informations client", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Votre nom",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Entrez votre nom" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: "Téléphone",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? "Entrez un numéro valide" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: "Adresse de livraison",
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? "Entrez une adresse" : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(selectedTime == null
                                ? "Choisissez une heure de livraison"
                                : "Heure : ${selectedTime!.format(context)}"),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time),
                            label: const Text("Choisir"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Menu & quantité
              Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.restaurant['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(widget.restaurant['plat']),
                  subtitle: Text("${widget.restaurant['price']} FCFA"),
                  trailing: QuantitySelector(
                    quantity: int.tryParse(widget.restaurant['quantity'].toString()) ?? 0,
                    onChanged: (q) => setState(() => widget.restaurant['quantity'] = q.toString()),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: "Notes spéciales",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // --- Total & bouton
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total :", style: TextStyle(fontSize: 18)),
                          Text(
                            "$totalPrice FCFA",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitOrder,
                        icon: _isSubmitting
                            ? const SizedBox(
                            width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                            : const Icon(Icons.check),
                        label: Text(_isSubmitting ? "Traitement..." : "Confirmer la commande"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;

  const QuantitySelector({super.key, required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: quantity > 0 ? () => onChanged(quantity - 1) : null,
        ),
        Text('$quantity', style: const TextStyle(fontSize: 16)),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}
*/