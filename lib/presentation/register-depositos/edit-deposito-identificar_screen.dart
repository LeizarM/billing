import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/register-depositos_repository.dart';
import 'package:billing/application/register-depositos/register-depositvos_service.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'package:billing/domain/register-depositos/BancoXCuenta.dart';
import 'package:billing/domain/register-depositos/NotaRemision.dart';
import 'package:billing/utils/image_picker_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:billing/application/auth/local_storage_service.dart';

class EditDepositoScreen extends StatefulWidget {
  final DepositoCheque deposito;
  final Function? onSaved; // Optional callback when saved successfully

  const EditDepositoScreen({
    Key? key,
    required this.deposito,
    this.onSaved,
  }) : super(key: key);

  @override
  State<EditDepositoScreen> createState() => _EditDepositoScreenState();
}

class _EditDepositoScreenState extends State<EditDepositoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DepositoRepository _depositoRepository = DepositoRepositoryImpl();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  // Status variables
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Form fields
  List<Empresa> _empresas = [];
  List<BancoXCuenta> _bancos = [];
  List<NotaRemision> _notasRemision = [];
  List<NotaRemision> _notasRemisionSeleccionadas = [];
  
  Empresa? _empresaSeleccionada;
  SocioNegocio? _socioSeleccionado;
  BancoXCuenta? _bancoSeleccionado;
  bool _loadingNotasRemision = false;
  
  // For image handling
  Uint8List? _imageBytes;
  
  // Text controllers
  final TextEditingController _importeController = TextEditingController();
  final TextEditingController _aCuentaController = TextEditingController(text: '0.00');
  String _monedaSeleccionada = 'BS';
  
  // For timing operations
  Timer? _notesResetTimer;
  Timer? _bankResetTimer;

  final List<Map<String, String>> _monedas = [
    {'value': 'BS', 'label': 'Bolivianos'},
    {'value': 'USD', 'label': 'Dólares'},
  ];

  // Added to track if the totals are valid
  bool _isTotalValid = true;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    
    // Add listeners to validate in real-time
    _importeController.addListener(_validarTotales);
    _aCuentaController.addListener(_validarTotales);
  }
  
  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load companies
      final empresasResult = await _depositoRepository.getEmpresas();
      setState(() {
        _empresas = empresasResult;
        
        // Initialize from deposito if available
        if (widget.deposito.codEmpresa != null) {
          _empresaSeleccionada = _empresas.firstWhere(
            (e) => e.codEmpresa == widget.deposito.codEmpresa,
            orElse: () => Empresa(),
          );
        }
        
        // Set form values from deposito
        _importeController.text = widget.deposito.importe?.toStringAsFixed(2) ?? '0.00';
        _aCuentaController.text = widget.deposito.aCuenta?.toStringAsFixed(2) ?? '0.00';
        _monedaSeleccionada = widget.deposito.moneda ?? 'BS';
      });
      
      // Load banks if company is selected
      if (_empresaSeleccionada?.codEmpresa != null) {
        await _cargarBancos(_empresaSeleccionada!.codEmpresa!);
        
        // Set selected bank based on deposito
        if (widget.deposito.idBxC != null) {
          setState(() {
            _bancoSeleccionado = _bancos.firstWhere(
              (b) => b.idBxC == widget.deposito.idBxC,
              orElse: () => BancoXCuenta(),
            );
          });
        }
      }
      
    } catch (e) {
      _mostrarError('Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _importeController.removeListener(_validarTotales);
    _aCuentaController.removeListener(_validarTotales);
    _importeController.dispose();
    _aCuentaController.dispose();
    _notesResetTimer?.cancel();
    _bankResetTimer?.cancel();
    super.dispose();
  }

  // Load banks based on selected company
  Future<void> _cargarBancos(int codEmpresa) async {
    // Cancel any existing auto-reset timer
    _bankResetTimer?.cancel();
    
    print('🏦 Loading banks for company $codEmpresa'); // Debug log
    
    // Clear the current bank list and selection before loading new ones
    setState(() {
      _isLoading = true;
      _bancos = []; // Clear existing banks immediately
      _bancoSeleccionado = null; // Reset selection
    });
    
    // Set up a safety timeout to force reset loading state after 8 seconds
    _bankResetTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        print('⚠️ Force resetting bank loading state after timeout'); // Debug log
        setState(() => _isLoading = false);
      }
    });
    
    try {
      final bancosResult = await _depositoRepository.getBancos(codEmpresa);
      
      print('✅ Banks loaded: ${bancosResult.length}'); // Debug log
      
      // Always ensure we update the state properly
      if (mounted) {
        setState(() {
          _bancos = bancosResult;
          _isLoading = false; // Explicitly set to false
        });
      }
    } catch (e) {
      print('❌ Error loading banks: $e'); // Debug log
      _mostrarError('Error al cargar bancos: $e');
      
      // Ensure loading state is reset even on errors
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Load remission notes based on selected company and client
  Future<void> _cargarNotasRemision(int codEmpresa, String codCliente) async {
    // Cancel any existing auto-reset timer
    _notesResetTimer?.cancel();
    
    print('⬇️ Starting to load notes for client $codCliente'); // Debug log
    
    // IMPORTANT: Always reset state at the beginning
    setState(() => _loadingNotasRemision = true);
    
    // Set up a safety timeout to force reset loading state after 8 seconds
    _notesResetTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _loadingNotasRemision) {
        print('⚠️ Force resetting notes loading state after timeout'); // Debug log
        setState(() => _loadingNotasRemision = false);
      }
    });
    
    try {
      final notasResult = await _depositoRepository.getNotasRemision(
        codEmpresa,
        codCliente,
      );
      
      print('✅ Notes loaded: ${notasResult.length}'); // Debug log
      
      // Always ensure we update the state after loading, regardless of result
      if (mounted) {
        setState(() {
          _notasRemision = notasResult;
          _notasRemisionSeleccionadas = [];
          _loadingNotasRemision = false; // Explicitly set to false
        });
      }
      
    } catch (e) {
      print('❌ Error loading notes: $e'); // Debug log
      _mostrarError('Error al cargar notas de remisión: $e');
      
      // Ensure loading state is reset even on errors
      if (mounted) {
        setState(() => _loadingNotasRemision = false);
      }
    }
  }
  
  // Helper to show error messages
  void _mostrarError(String mensaje) {
    setState(() {
      _errorMessage = mensaje;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  // Helper to show success messages
  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Image picker methods
  Future<void> _pickImage() async {
    try {
      final result = await ImagePickerHelper.pickImage();
      if (result != null) {
        setState(() {
          _imageBytes = result.bytes;
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    }
  }
  
  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _mostrarError('Error al capturar imagen: $e');
    }
  }
  
  // Calculate total from selected notes
  double _calcularTotalNotasSeleccionadas() {
    if (_notasRemisionSeleccionadas.isEmpty) return 0.0;
    return _notasRemisionSeleccionadas.fold(
      0.0, (sum, nota) => sum + (nota.saldoPendiente ?? 0.0));
  }
  
  // Calculate total including "a cuenta"
  double _calcularTotalGeneral() {
    double totalNotas = _calcularTotalNotasSeleccionadas();
    double aCuenta = double.tryParse(_aCuentaController.text) ?? 0.0;
    return totalNotas + aCuenta;
  }
  
  // Update validation state - replaces _actualizarImporteTotal
  void _validarTotales() {
    final totalCalculado = _calcularTotalGeneral();
    final importeTotal = double.tryParse(_importeController.text) ?? 0.0;
    
    // Check if the difference is more than a small rounding error
    final bool isValid = (importeTotal - totalCalculado).abs() <= 0.01;
    
    setState(() {
      _isTotalValid = isValid;
      if (!isValid) {
        final diff = (importeTotal - totalCalculado).abs();
        _validationMessage = 'La sumatoria de notas y a cuenta debe ser igual al importe (diferencia: ${diff.toStringAsFixed(2)})';
      } else {
        _validationMessage = null;
      }
    });
  }
  
  // Helper to format currency values
  String _formatCurrency(double? amount) {
    if (amount == null) return '-';
    final formatter = NumberFormat.currency(
      symbol: '', 
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Nota remision selector dialog
  void _showNotaRemisionSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _NotaRemisionSelectorModal(
          notas: _notasRemision,
          selectedNotas: List.from(_notasRemisionSeleccionadas),
          onSave: (selectedItems) {
            setState(() {
              _notasRemisionSeleccionadas = selectedItems;
              // Validate totals after notes selection changes
              _validarTotales();
            });
          },
        );
      },
    );
  }
  
  // Save the deposit
  Future<void> _guardarDeposito() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarError('Complete todos los campos requeridos');
      return;
    }
    
    if (_empresaSeleccionada == null ||
        _socioSeleccionado == null ||
        _bancoSeleccionado == null) {
      _mostrarError('Complete todos los campos requeridos');
      return;
    }
    
    // Check if either notes are selected or there's an "a cuenta" amount
    double aCuenta = double.tryParse(_aCuentaController.text) ?? 0.0;
    if (_notasRemisionSeleccionadas.isEmpty && aCuenta <= 0) {
      _mostrarError('Debe seleccionar al menos una nota de remisión o ingresar un monto a cuenta');
      return;
    }
    
    // Get the total of notes
    double totalNotas = _calcularTotalNotasSeleccionadas();
    // Get total importe
    double importeTotal = double.tryParse(_importeController.text) ?? 0.0;
    // Calculate expected total
    double expectedTotal = totalNotas + aCuenta;
    
    // Validate that importe equals the sum of notes and a cuenta
    if ((importeTotal - expectedTotal).abs() > 0.01) { // Allow small rounding differences
      _mostrarError('El importe total debe ser igual a la suma de notas seleccionadas más el monto a cuenta');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get the user from local storage
      final user = await _localStorageService.getUser();
      if (user == null) {
        _mostrarError('No se pudo obtener la información del usuario');
        setState(() => _isLoading = false);
        return;
      }
      
      // Prepare the deposit object
      final depositoActualizado = DepositoCheque(
        idDeposito: widget.deposito.idDeposito ?? 0,
        codEmpresa: _empresaSeleccionada!.codEmpresa,
        codCliente: _socioSeleccionado!.codCliente,
        idBxC: _bancoSeleccionado!.idBxC,
        estado: 1,
        obs: widget.deposito.obs,
        importe: double.parse(_importeController.text),
        moneda: _monedaSeleccionada,
        audUsuario: user.codUsuario,
        aCuenta: double.parse(_aCuentaController.text),
      );
      
      // Convert image bytes to file if present
      File? imageFile;
      if (_imageBytes != null) {
        final tempDir = await Directory.systemTemp.createTemp();
        final tempFile = File('${tempDir.path}/temp_image.jpg');
        await tempFile.writeAsBytes(_imageBytes!);
        imageFile = tempFile;
      } else if (widget.deposito.idDeposito == null) {
        // If it's a new deposit, we need an image file
        _mostrarError('Debe seleccionar una imagen del comprobante de depósito');
        setState(() => _isLoading = false);
        return;
      }
      
      // Validate that importe equals the sum of notes and a cuenta
      double totalNotas = _calcularTotalNotasSeleccionadas();
      double aCuenta = double.tryParse(_aCuentaController.text) ?? 0.0;
      double importeTotal = double.tryParse(_importeController.text) ?? 0.0;
      double expectedTotal = totalNotas + aCuenta;
      
      // Check if there's a mismatch between expected total and importe
      if ((importeTotal - expectedTotal).abs() > 0.01) { // Allow small rounding differences
        _mostrarError('El importe total debe ser exactamente igual a la suma de notas seleccionadas más el monto a cuenta');
        setState(() => _isLoading = false);
        return;
      }
      
      // Register or update the deposit
      final exito = await _depositoRepository.registrarDeposito(
        depositoActualizado,
        imageFile!,
      );
      
      if (!exito) {
        _mostrarError('Error al guardar el depósito');
        setState(() => _isLoading = false);
        return;
      }
      
      // Now that the deposit is saved, we need its ID to link with notes
      int depositoId = depositoActualizado.idDeposito ?? widget.deposito.idDeposito ?? 0;
      
      if (depositoId == 0) {
        _mostrarError('Error: No se pudo obtener el ID del depósito');
        setState(() => _isLoading = false);
        return;
      }
      
      // Save remission notes
      bool allNotesSaved = true;
      
      // Link each note to this deposit and save them
      for (final nota in _notasRemisionSeleccionadas) {
        try {
          // Set deposit ID in each note before saving
          nota.idDeposito = depositoId;
          // Add required user info if missing
          nota.audUsuario = user.codUsuario;
          
          // Ensure empresa is set
          if (nota.codEmpresaBosque == null && _empresaSeleccionada != null) {
            nota.codEmpresaBosque = _empresaSeleccionada!.codEmpresa;
          }
          
          // Save the note to the backend
          final success = await _depositoRepository.guardarNotaRemision(nota);
          
          if (!success) {
            _mostrarError('Error al guardar la nota de remisión #${nota.docNum}');
            allNotesSaved = false;
            break;
          }
        } catch (e) {
          _mostrarError('Error al procesar nota #${nota.docNum}: $e');
          allNotesSaved = false;
          break;
        }
      }
      
      if (allNotesSaved) {
        _mostrarMensajeExito('Depósito actualizado exitosamente');
        
        // Call the onSaved callback if provided
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
        
        // Return to previous screen
        Navigator.pop(context, true); 
      } else {
        _mostrarError('El depósito se guardó pero hubo errores al guardar algunas notas');
      }
    } catch (e) {
      _mostrarError('Error al guardar el depósito: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Depósito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar cambios',
            onPressed: _isLoading ? null : _guardarDeposito,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deposit info header
                  _buildDepositInfoHeader(),
                  const SizedBox(height: 20),
                  
                  // Company selection
                  _buildCompanyDropdown(),
                  const SizedBox(height: 16),
                  
                  // Client selection
                  _buildClientSelection(),
                  const SizedBox(height: 16),
                  
                  // Bank selection
                  _buildBankSelection(),
                  const SizedBox(height: 16),
                  
                  // Notes selection
                  if (_socioSeleccionado != null)
                    _buildNotesSelection(),
                  const SizedBox(height: 16),
                  
                  // A cuenta field
                  _buildACuentaField(),
                  const SizedBox(height: 16),
                  
                  // Importe total field (read-only)
                  _buildImporteField(),
                  const SizedBox(height: 16),
                  
                  // Currency selection
                  _buildMonedaDropdown(),
                  const SizedBox(height: 20),
                  
                  // Image selector
                  _buildImageSelector(),
                  const SizedBox(height: 30),
                  
                  // Save button
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDepositInfoHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Depósito',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text('ID Depósito: ${widget.deposito.idDeposito ?? '-'}'),
                ),
                Expanded(
                  child: Text('Banco: ${widget.deposito.nombreBanco ?? '-'}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Importe: ${_formatCurrency(widget.deposito.importe)} ${widget.deposito.moneda ?? ''}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Empresa',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        // Replace DropdownButtonFormField with a non-editable display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100, // Light gray background to indicate read-only
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.business, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _empresaSeleccionada?.nombre ?? 'No seleccionada',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.lock, color: Colors.grey, size: 16), // Lock icon to indicate read-only
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientSelection() {
    return ClienteSearchField(
      repository: _depositoRepository,
      empresa: _empresaSeleccionada,
      initialValue: _socioSeleccionado,
      enabled: _empresaSeleccionada != null,
      onSelect: (cliente) {
        setState(() {
          _socioSeleccionado = cliente;
        });
        
        if (_empresaSeleccionada != null && _socioSeleccionado != null) {
          _cargarNotasRemision(
            _empresaSeleccionada!.codEmpresa!,
            _socioSeleccionado!.codCliente!,
          );
        }
      },
    );
  }

  Widget _buildBankSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banco', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoading ? 
            const ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Cargando bancos...'),
            ) :
            DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<BancoXCuenta>(
                  isExpanded: true,
                  hint: const Text('Seleccione un banco'),
                  value: _bancoSeleccionado,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: (BancoXCuenta? newValue) {
                    setState(() {
                      _bancoSeleccionado = newValue;
                    });
                  },
                  items: _bancos.map<DropdownMenuItem<BancoXCuenta>>((BancoXCuenta banco) {
                    return DropdownMenuItem<BancoXCuenta>(
                      value: banco,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          banco.nombreBanco ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ),
        if (_bancos.isEmpty && !_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'No hay bancos disponibles para esta empresa',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notas de Remisión', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _loadingNotasRemision ? null : _showNotaRemisionSelector,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _loadingNotasRemision ? Colors.orange : Colors.grey.shade400
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: _loadingNotasRemision
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Cargando notas...'),
                        ],
                      )
                    : _notasRemision.isEmpty
                      ? const Text('No hay notas disponibles')
                      : Text(
                          _notasRemisionSeleccionadas.isEmpty
                            ? 'Seleccionar notas de remisión'
                            : '${_notasRemisionSeleccionadas.length} notas seleccionadas',
                        ),
                ),
                // Refresh button
                if (_loadingNotasRemision || (_notasRemision.isEmpty && _socioSeleccionado != null))
                  IconButton(
                    icon: Icon(
                      _loadingNotasRemision ? Icons.refresh : Icons.refresh_outlined,
                      color: _loadingNotasRemision ? Colors.orange : Colors.teal,
                    ),
                    onPressed: () {
                      _notesResetTimer?.cancel();
                      setState(() => _loadingNotasRemision = false);
                      
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (_empresaSeleccionada != null && _socioSeleccionado != null) {
                          _cargarNotasRemision(
                            _empresaSeleccionada!.codEmpresa!,
                            _socioSeleccionado!.codCliente!,
                          );
                        }
                      });
                    },
                  )
                else
                  const Icon(Icons.arrow_drop_down, color: Colors.teal),
              ],
            ),
          ),
        ),
        // Show selected notes summary
        if (_notasRemisionSeleccionadas.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: ${_formatCurrency(_calcularTotalNotasSeleccionadas())}'),
                const Divider(),
                for (var nota in _notasRemisionSeleccionadas.take(3))
                  Text('Doc: ${nota.docNum} - ${_formatCurrency(nota.saldoPendiente)}'),
                if (_notasRemisionSeleccionadas.length > 3)
                  Text('y ${_notasRemisionSeleccionadas.length - 3} más...'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildACuentaField() {
    return TextFormField(
      controller: _aCuentaController,
      decoration: InputDecoration(
        labelText: 'A Cuenta',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.add_card),
        // Show error if validation fails
        errorText: _validationMessage,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo requerido';
        }
        if (double.tryParse(value) == null) {
          return 'Valor inválido';
        }
        return null;
      },
      onChanged: (value) {
        // Validate without updating importe
        _validarTotales();
      },
    );
  }

  Widget _buildImporteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Importe Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _isTotalValid ? Colors.teal.shade300 : Colors.red.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _importeController,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _isTotalValid ? Colors.teal.shade700 : Colors.red.shade700,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.attach_money),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              // Validate whenever importe changes
              _validarTotales();
            },
          ),
        ),
        if (!_isTotalValid)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _validationMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonedaDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Moneda',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.currency_exchange),
      ),
      value: _monedaSeleccionada,
      items: _monedas.map((moneda) {
        return DropdownMenuItem<String>(
          value: moneda['value'],
          child: Text(moneda['label']!),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _monedaSeleccionada = value);
        }
      },
    );
  }

  Widget _buildImageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comprobante de Depósito',
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 8),
          if (_imageBytes != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _imageBytes!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() {
                        _imageBytes = null;
                      }),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.close, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: Text(_imageBytes == null ? 'Galería' : 'Cambiar Imagen'),
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                  onPressed: _pickImageFromCamera,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text(
          'Guardar Cambios',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: _isLoading || !_isTotalValid ? null : _guardarDeposito,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // Disabled state styling
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white,
        ),
      ),
    );
  }
}

// High-performance direct search client component
class ClienteSearchField extends StatefulWidget {
  final DepositoRepository repository;
  final Empresa? empresa;
  final SocioNegocio? initialValue;
  final Function(SocioNegocio) onSelect;
  final bool enabled;

  const ClienteSearchField({
    Key? key,
    required this.repository,
    required this.empresa,
    this.initialValue,
    required this.onSelect,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ClienteSearchField> createState() => _ClienteSearchFieldState();
}

class _ClienteSearchFieldState extends State<ClienteSearchField> {
  // We'll use a debounced search timer
  Timer? _debounceTimer;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cliente', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: !widget.enabled || widget.empresa == null ? null : () {
            _showSearchDialog(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: widget.enabled ? Colors.grey.shade400 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              color: widget.enabled ? null : Colors.grey.shade50,
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.initialValue == null
                      ? 'Buscar cliente...'
                      : '${widget.initialValue!.codCliente} - ${widget.initialValue!.nombreCompleto}',
                    style: TextStyle(
                      color: widget.initialValue == null ? Colors.grey.shade600 : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.search, color: Colors.teal),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DirectSearchDialog(
        repository: widget.repository,
        empresa: widget.empresa!,
        onSelect: (cliente) {
          widget.onSelect(cliente);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Implement the direct search dialog
class _DirectSearchDialog extends StatefulWidget {
  final DepositoRepository repository;
  final Empresa empresa;
  final Function(SocioNegocio) onSelect;

  const _DirectSearchDialog({
    Key? key,
    required this.repository,
    required this.empresa,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<_DirectSearchDialog> createState() => _DirectSearchDialogState();
}

class _DirectSearchDialogState extends State<_DirectSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<SocioNegocio> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';
  bool _hasSearched = false;
  
  // Track recent selections for quick access
  List<SocioNegocio> _recentSelections = [];
  bool _showRecents = true;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _showRecents = true;
        _searchResults = [];
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      if (query.length >= 3) {
        _performSearch(query);
      } else {
        setState(() {
          _showRecents = true;
          _searchResults = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 3) return;
    
    setState(() {
      _isSearching = true;
      _errorMessage = '';
      _showRecents = false;
    });
    
    try {
      // Load a small subset of clients from server based on search query
      final allClients = await widget.repository.getSociosNegocio(widget.empresa.codEmpresa!);
      
      // Filter locally - in a real app, this filtering would be done on the server
      final filteredClients = allClients.where((client) {
        final nombre = client.nombreCompleto?.toLowerCase() ?? '';
        final codigo = client.codCliente?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return nombre.contains(searchLower) || codigo.contains(searchLower);
      }).take(20).toList(); // Only take first 20 results for performance
      
      setState(() {
        _searchResults = filteredClients;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al buscar clientes: $e';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.search, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Buscar Cliente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ingrese al menos 3 caracteres para buscar',
                  prefixIcon: const Icon(Icons.person_search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                ),
                autofocus: true,
              ),
            ),
            
            // Status messages and search results (similar to the existing code)
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Buscando clientes...'),
                  ],
                ),
              ),
            
            // Other status messages and results
            if (_errorMessage.isNotEmpty) 
              // Error message
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            
            // Results list
            Expanded(
              child: _hasSearched 
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final cliente = _searchResults[index];
                      return _buildClientItem(cliente);
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Busque un cliente por nombre o código',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildClientItem(SocioNegocio cliente) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => widget.onSelect(cliente),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombreCompleto ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Código: ${cliente.codCliente}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// RemissionNoteSelector modal - similar to the existing modal class
class _NotaRemisionSelectorModal extends StatefulWidget {
  final List<NotaRemision> notas;
  final List<NotaRemision> selectedNotas;
  final Function(List<NotaRemision>) onSave;

  const _NotaRemisionSelectorModal({
    Key? key, 
    required this.notas,
    required this.selectedNotas,
    required this.onSave,
  }) : super(key: key);

  @override
  _NotaRemisionSelectorModalState createState() => _NotaRemisionSelectorModalState();
}

class _NotaRemisionSelectorModalState extends State<_NotaRemisionSelectorModal> {
  late List<NotaRemision> _tempSelectedNotas;
  final TextEditingController _searchController = TextEditingController();
  List<NotaRemision> _filteredNotas = [];
  
  final formatCurrency = NumberFormat.currency(
    locale: 'es_BO',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _tempSelectedNotas = List.from(widget.selectedNotas);
    _filteredNotas = widget.notas;
  }
  
  double _calcularTotal() {
    return _tempSelectedNotas.fold(
        0.0, (sum, nota) => sum + (nota.saldoPendiente ?? 0.0));
  }
  
  void _filterNotas(String query) {
    setState(() {
      _filteredNotas = widget.notas.where((nota) {
        final docNum = nota.docNum?.toString().toLowerCase() ?? '';
        final numFact = nota.numFact?.toString().toLowerCase() ?? '';
        final search = query.toLowerCase();
        
        return docNum.contains(search) || 
               numFact.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // UI components for the modal (similar to existing code)
          Container(
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Seleccionar notas de remisión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por documento o factura...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterNotas('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterNotas,
          ),
          const SizedBox(height: 16),
          
          // Rest of the modal UI similar to existing code
          // Summary section, select/deselect buttons, and notes list
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionados: ${_tempSelectedNotas.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total: ${formatCurrency.format(_calcularTotal())}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Buttons
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.check_box_outlined),
                label: const Text('Seleccionar todos'),
                onPressed: () {
                  setState(() {
                    _tempSelectedNotas = List.from(_filteredNotas);
                  });
                },
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.check_box_outline_blank),
                label: const Text('Desmarcar todos'),
                onPressed: () {
                  setState(() {
                    _tempSelectedNotas.clear();
                  });
                },
              ),
            ],
          ),
          
          // Notes list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotas.length,
              itemBuilder: (context, index) {
                final nota = _filteredNotas[index];
                final isSelected = _tempSelectedNotas.any(
                  (selected) => selected.docNum == nota.docNum && 
                               selected.numFact == nota.numFact
                );
                
                final fecha = nota.fecha != null
                    ? DateFormat('dd/MM/yyyy').format(nota.fecha!)
                    : 'Sin fecha';
                    
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Colors.teal : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _tempSelectedNotas.removeWhere(
                            (item) => item.docNum == nota.docNum && 
                                     item.numFact == nota.numFact
                          );
                        } else {
                          _tempSelectedNotas.add(nota);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _tempSelectedNotas.add(nota);
                                } else {
                                  _tempSelectedNotas.removeWhere(
                                    (item) => item.docNum == nota.docNum && 
                                             item.numFact == nota.numFact
                                  );
                                }
                              });
                            },
                            activeColor: Colors.teal,
                          ),
                          // Rest of the row UI similar to existing code
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.description, size: 16, color: Colors.teal),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Doc: ${nota.docNum ?? 'N/A'}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.receipt, size: 16, color: Colors.teal),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Fact: ${nota.numFact ?? 'N/A'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Fecha: $fecha',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                Row(
                                  children: [
                                    const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Saldo: ${formatCurrency.format(nota.saldoPendiente ?? 0)}',
                                        style: TextStyle(
                                          fontSize: 13, 
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(_tempSelectedNotas);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('Guardar selección'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
