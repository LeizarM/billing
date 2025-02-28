import 'dart:io';
import 'dart:typed_data';
import 'package:billing/application/auth/local_storage_service.dart';
import 'package:billing/application/register-depositos/register-depositvos_service.dart';
import 'package:billing/domain/register-depositos/ChBanco.dart';
import 'package:billing/domain/register-depositos/DepositoCheque.dart';
import 'package:billing/domain/register-depositos/Empresa.dart';
import 'package:billing/domain/register-depositos/SocioNegocio.dart';
import 'package:billing/utils/image_picker_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  final TextEditingController _docNumController = TextEditingController();
  final TextEditingController _importeController = TextEditingController();
  final TextEditingController _numFactController = TextEditingController();

  Uint8List? _imageBytes;
  String? _fileName;

  // Usamos PlatformFile para manejar archivos en web (bytes) y en móvil (ruta)
  bool _isLoading = false;
  List<Empresa> _empresas = [];
  List<SocioNegocio> _socios = [];
  List<ChBanco> _bancos = [];

  Empresa? _empresaSeleccionada;
  SocioNegocio? _socioSeleccionado;
  ChBanco? _bancoSeleccionado;
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

      _imageBytes = null;
      _fileName = null;
      _docNumController.clear();
      _importeController.clear();
      _numFactController.clear();
    });
  }

  @override
  void dispose() {
    _docNumController.dispose();
    _importeController.dispose();
    _numFactController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() => _isLoading = true);
    try {
      final empresasResult = await depositoRepository.getEmpresas();
      final bancosResult = await depositoRepository.getBancos();
      setState(() {
        _empresas = empresasResult;
        _bancos = bancosResult;
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

  /// Seleccionar imagen desde la galería (file_picker)
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

  /// Capturar imagen usando la cámara (image_picker)
  /*Future<void> _pickImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      final int size = await image.length();
      Uint8List? imageBytes;
      // En web se puede leer también la imagen (si el navegador lo soporta)
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      }
      setState(() {
        _imagenFile = PlatformFile(
          name: image.name,
          size: size,
          path: image.path,
          bytes: imageBytes,
        );
      });
      print('Imagen capturada: ${_imagenFile!.name}');
    } else {
      print('No se capturó imagen');
    }
  }*/

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
        docNum: int.tryParse(_docNumController.text),
        codBanco: _bancoSeleccionado!.codBanco,
        importe: double.parse(_importeController.text).toInt(),
        moneda: _monedaSeleccionada,
        numFact: int.parse(_numFactController.text),
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

  @override
  Widget build(BuildContext context) {
    // Se decide mostrar el botón de cámara si la plataforma es Android o iOS
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
                          TextFormField(
                            controller: _docNumController,
                            decoration: _inputDecoration('Número de Documento',
                                icon: Icons.description),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Campo requerido'
                                    : null,
                          ),
                          const SizedBox(height: kFieldSpacing),
                          TextFormField(
                            controller: _numFactController,
                            decoration: _inputDecoration('Número de Factura',
                                icon: Icons.receipt_long),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'Campo requerido'
                                    : null,
                          ),
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
        });
        if (value != null) {
          if (value.codEmpresa == 7) {
            _cargarSocios(1);
          } else {
            _cargarSocios(value.codEmpresa!);
          }
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
          },
        );
      },
    );
  }

  Widget _buildBancoDropdown() {
    return DropdownButtonFormField<ChBanco>(
      decoration: _inputDecoration('Banco', icon: Icons.account_balance),
      value: _bancoSeleccionado,
      items: _bancos.map((banco) {
        return DropdownMenuItem<ChBanco>(
          value: banco,
          child: Text(banco.nombre ?? ''),
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
