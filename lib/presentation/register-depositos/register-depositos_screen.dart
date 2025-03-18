import 'dart:io';
import 'dart:typed_data';
import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/register-depositos/register-depositvos_service.dart';
import 'package:billing/domain/register-depositos/BancoXCuenta.dart';
import 'package:billing/domain/register-depositos/ChBanco.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/NotaRemision.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'package:billing/utils/image_picker_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Estilos globales
const double kPadding = 16.0;
const double kFieldSpacing = 16.0;
const double kBorderRadius = 12.0;

class RegistrarDepositoPage extends StatefulWidget {
  const RegistrarDepositoPage({Key? key}) : super(key: key);

  @override
  State<RegistrarDepositoPage> createState() => _RegistrarDepositoPageState();
}

class _RegistrarDepositoPageState extends State<RegistrarDepositoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final LocalStorageService _localStorageService = LocalStorageService();
  final DepositoRepositoryImpl depositoRepository = DepositoRepositoryImpl();

  final TextEditingController _importeController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileName;

  bool _isLoading = false;
  List<Empresa> _empresas = [];
  List<SocioNegocio> _socios = [];
  List<BancoXCuenta> _bancos = [];

  List<NotaRemision> _notasRemision = [];
  List<NotaRemision> _notasRemisionSeleccionadas = [];
  bool _loadingNotasRemision = false;

  Empresa? _empresaSeleccionada;
  SocioNegocio? _socioSeleccionado;
  BancoXCuenta? _bancoSeleccionado;
  String _monedaSeleccionada = 'BS';

  final List<Map<String, String>> _monedas = [
    {'value': 'BS', 'label': 'Bolivianos'},
    {'value': 'USD', 'label': 'Dólares'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadius),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    );
  }

  void _limpiarFormulario() {
    setState(() {
      _empresaSeleccionada = null;
      _socioSeleccionado = null;
      _bancoSeleccionado = null;
      _monedaSeleccionada = 'BS';
      _notasRemision = [];
      _notasRemisionSeleccionadas = [];

      _imageBytes = null;
      _fileName = null;
      _importeController.clear();
    });
  }

  @override
  void dispose() {
    _importeController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final empresasResult = await depositoRepository.getEmpresas();
      setState(() {
        _empresas = empresasResult;
      });
    } catch (e) {
      _mostrarError('Error al cargar datos iniciales: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarSocios(int codEmpresa) async {
    setState(() => _isLoading = true);
    try {
      final sociosResult =
          await depositoRepository.getSociosNegocio(codEmpresa);
      setState(() {
        _socios = sociosResult;
      });
    } catch (e) {
      _mostrarError('Error al cargar socios: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarBancos(int codEmpresa) async {
    setState(() => _isLoading = true);
    try {
      final bancosResult = await depositoRepository.getBancos(codEmpresa);
      setState(() {
        _bancos = bancosResult;
        _bancoSeleccionado = null;
      });
    } catch (e) {
      _mostrarError('Error al cargar bancos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarNotasRemision(int codEmpresa, String codCliente) async {
    setState(() => _loadingNotasRemision = true);
    try {
      final notasResult = await depositoRepository.getNotasRemision(
        codEmpresa,
        codCliente,
      );
      setState(() {
        _notasRemision = notasResult;
        _notasRemisionSeleccionadas = [];
      });
    } catch (e) {
      _mostrarError('Error al cargar notas de remisión: $e');
    } finally {
      setState(() => _loadingNotasRemision = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await ImagePickerHelper.pickImage();

      if (result != null) {
        setState(() {
          _imageBytes = result.bytes;
          _fileName = result.fileName;
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Error al seleccionar imagen. Por favor, intente nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

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
        margin: const EdgeInsets.all(kPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _registrarDeposito() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarError('Complete todos los campos requeridos');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _localStorageService.getUser();
      final deposito = DepositoCheque(
        idDeposito: 0,
        codEmpresa: _empresaSeleccionada!.codEmpresa,
        codCliente: _socioSeleccionado!.codCliente,
        idBxC: _bancoSeleccionado!.idBxC,
        importe: double.parse(_importeController.text).toInt(),
        moneda: _monedaSeleccionada,
        audUsuario: user?.codUsuario,
      );
      final registroExitoso = await depositoRepository.registrarDeposito(
        deposito,
        _imageBytes,
      );
      if (registroExitoso) {
        _mostrarMensajeExito('Depósito registrado exitosamente');
        _limpiarFormulario();
      }
    } catch (e) {
      final errorMsg = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ')[1]
          : e.toString();
      _mostrarErrorDialog(errorMsg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  double _calcularTotalNotasSeleccionadas() {
    if (_notasRemisionSeleccionadas.isEmpty) return 0.0;
    return _notasRemisionSeleccionadas.fold(
        0.0, (sum, nota) => sum + (nota.saldoPendiente ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    bool showCameraButton = (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet),
            SizedBox(width: 8),
            Text('Registrar Depósito'),
          ],
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(kPadding),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: kPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(kPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEmpresaDropdown(),
                          const SizedBox(height: kFieldSpacing),
                          _buildClienteDropdown(),
                          const SizedBox(height: kFieldSpacing),
                          _buildNotaRemisionSelector(),
                          const SizedBox(height: kFieldSpacing),
                          _buildBancoDropdown(),
                          const SizedBox(height: kFieldSpacing),
                          TextFormField(
                            controller: _importeController,
                            decoration: _inputDecoration('Importe',
                                icon: Icons.attach_money),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Campo requerido';
                              if (double.tryParse(value) == null)
                                return 'Importe inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: kFieldSpacing),
                          _buildMonedaDropdown(),
                          const SizedBox(height: kFieldSpacing * 1.5),
                          _buildImagenSelector(showCameraButton),
                          const SizedBox(height: kFieldSpacing * 1.5),
                          ElevatedButton.icon(
                            onPressed: _registrarDeposito,
                            icon: const Icon(Icons.send),
                            label: const Text(
                              'Registrar Depósito',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(kBorderRadius),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmpresaDropdown() {
    return DropdownButtonFormField<Empresa>(
      decoration: _inputDecoration('Empresa', icon: Icons.business),
      value: _empresaSeleccionada,
      items: _empresas.map((empresa) {
        return DropdownMenuItem<Empresa>(
          value: empresa,
          child: Text(empresa.nombre ?? ''),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _empresaSeleccionada = value;
          _socioSeleccionado = null;
          _bancoSeleccionado = null;
        });
        if (value != null) {
          if (value.codEmpresa == 7) {
            _cargarSocios(1);
          } else {
            _cargarSocios(value.codEmpresa!);
          }
          _cargarBancos(value.codEmpresa!);
        }
      },
      validator: (value) => value == null ? 'Seleccione una empresa' : null,
    );
  }

  Widget _buildClienteDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _empresaSeleccionada == null
              ? null
              : () => _showClienteSearch(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _socioSeleccionado == null
                        ? 'Seleccione un cliente'
                        : '${_socioSeleccionado!.codCliente} - ${_socioSeleccionado!.nombreCompleto}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _socioSeleccionado == null
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: _empresaSeleccionada == null
                      ? Colors.grey.shade400
                      : Colors.teal,
                ),
              ],
            ),
          ),
        ),
        if (_socioSeleccionado == null &&
            (_formKey.currentState != null &&
                !_formKey.currentState!.validate()))
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Seleccione un cliente',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  void _showClienteSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _ClienteSearchModal(
          socios: _socios,
          onSelect: (cliente) {
            setState(() {
              _socioSeleccionado = cliente;
            });
            Navigator.pop(context);
            if (_empresaSeleccionada != null && _socioSeleccionado != null) {
              _cargarNotasRemision(
                _empresaSeleccionada!.codEmpresa!,
                _socioSeleccionado!.codCliente!,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildBancoDropdown() {
    return DropdownButtonFormField<BancoXCuenta>(
      decoration: _inputDecoration('Banco', icon: Icons.account_balance),
      value: _bancoSeleccionado,
      isExpanded: true,
      menuMaxHeight: 300,
      items: _bancos.map((banco) {
        return DropdownMenuItem<BancoXCuenta>(
          value: banco,
          child: Text(
            banco.nombreBanco ?? '',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _bancoSeleccionado = value),
      validator: (value) => value == null ? 'Seleccione un banco' : null,
    );
  }

  Widget _buildMonedaDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration('Moneda', icon: Icons.money),
      value: _monedaSeleccionada,
      items: _monedas.map((moneda) {
        return DropdownMenuItem<String>(
          value: moneda['value'],
          child: Text(moneda['label']!),
        );
      }).toList(),
      onChanged: (value) => setState(() => _monedaSeleccionada = value!),
      validator: (value) => value == null ? 'Seleccione una moneda' : null,
    );
  }

  Widget _buildImagePreview() {
    if (_imageBytes == null) return const SizedBox.shrink();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(kBorderRadius),
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
                _fileName = null;
              }),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagenSelector(bool showCameraButton) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          if (_imageBytes != null) ...[
            _buildImagePreview(),
            const SizedBox(height: kFieldSpacing),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label:
                      Text(_imageBytes == null ? 'Galería' : 'Cambiar Imagen'),
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                  ),
                ),
              ),
              if (showCameraButton) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    onPressed: _pickImageFromCamera,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
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
        _fileName = image.name;  
      });  
    }  
  } catch (e) {  
    print('Error al capturar imagen: $e');  
    if (mounted) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(  
          content: Text('Error al capturar imagen. Por favor, intente nuevamente.'),  
          backgroundColor: Colors.red,  
        ),  
      );  
    }  
  }  
}

  Widget _buildNotaRemisionSelector() {
    if (_socioSeleccionado == null) {
      return const SizedBox.shrink();
    }
    
    if (_loadingNotasRemision) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_notasRemision.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(kBorderRadius),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No hay notas de remisión disponibles para este cliente.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'es_BO',
      symbol: '',
      decimalDigits: 2,
    );
    
    final totalSeleccionado = _calcularTotalNotasSeleccionadas();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showNotaRemisionSelector(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _notasRemisionSeleccionadas.isEmpty
                        ? 'Seleccionar notas de remisión'
                        : '${_notasRemisionSeleccionadas.length} notas seleccionadas',
                    style: TextStyle(
                      fontSize: 16,
                      color: _notasRemisionSeleccionadas.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.teal),
              ],
            ),
          ),
        ),
        
        if (_notasRemisionSeleccionadas.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(kBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notas seleccionadas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    Text(
                      '${_notasRemisionSeleccionadas.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    Text(
                      formatCurrency.format(totalSeleccionado),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                ..._notasRemisionSeleccionadas.take(3).map((nota) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Doc: ${nota.docNum} - ${formatCurrency.format(nota.saldoPendiente ?? 0)}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                if (_notasRemisionSeleccionadas.length > 3)
                  Text(
                    'y ${_notasRemisionSeleccionadas.length - 3} más...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
        
        if (_notasRemisionSeleccionadas.isEmpty &&
            (_formKey.currentState != null &&
                !_formKey.currentState!.validate()))
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Seleccione al menos una nota de remisión',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
  
  void _showNotaRemisionSelector(BuildContext context) {
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
              if (selectedItems.isNotEmpty) {
                final total = selectedItems.fold(
                    0.0, (sum, nota) => sum + (nota.saldoPendiente ?? 0.0));
                _importeController.text = total.toStringAsFixed(2);
              } else {
                _importeController.clear();
              }
            });
          },
        );
      },
    );
  }
}

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
      padding: const EdgeInsets.all(kPadding),
      child: Column(
        children: [
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
              Text(
                'Seleccionar notas de remisión',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por documento o factura...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
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
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(kBorderRadius),
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
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    side: BorderSide(
                      color: isSelected ? Colors.teal : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(kBorderRadius),
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
                                        'Monto: ${formatCurrency.format(nota.totalMonto ?? 0)}',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Saldo: ${formatCurrency.format(nota.saldoPendiente ?? 0)}',
                                      style: TextStyle(
                                        fontSize: 13, 
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                        borderRadius: BorderRadius.circular(kBorderRadius),
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
                        borderRadius: BorderRadius.circular(kBorderRadius),
                      ),
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

class _ClienteSearchModal extends StatefulWidget {
  final List<SocioNegocio> socios;
  final Function(SocioNegocio) onSelect;

  const _ClienteSearchModal({
    Key? key,
    required this.socios,
    required this.onSelect,
  }) : super(key: key);

  @override
  _ClienteSearchModalState createState() => _ClienteSearchModalState();
}

class _ClienteSearchModalState extends State<_ClienteSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  late List<SocioNegocio> _filteredSocios;

  @override
  void initState() {
    super.initState();
    _filteredSocios = widget.socios;
  }

  void _filterSocios(String query) {
    setState(() {
      _filteredSocios = widget.socios.where((socio) {
        final nombre = socio.nombreCompleto?.toLowerCase() ?? '';
        final codigo = socio.codCliente?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return nombre.contains(search) || codigo.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(kPadding),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 50,
            margin: const EdgeInsets.only(bottom: kFieldSpacing),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar cliente...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadius),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterSocios('');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
            onChanged: _filterSocios,
          ),
          const SizedBox(height: kFieldSpacing),
          Expanded(
            child: _filteredSocios.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredSocios.length,
                    itemBuilder: (context, index) {
                      final socio = _filteredSocios[index];
                      return InkWell(
                        onTap: () => widget.onSelect(socio),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.person, color: Colors.teal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      socio.nombreCompleto ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Código: ${socio.codCliente}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No se encontraron clientes')),
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
