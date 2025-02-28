import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

// Constantes de diseño
const double kPadding = 16.0;
const double kBorderRadius = 16.0;
const double kItemSpacing = 20.0;

// Tema moderno
class DetailTheme {
  static const Color primaryColor = Color(0xFF3F51B5); // Indigo
  static const Color accentColor = Color(0xFF00BCD4);  // Cyan
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF263238);
  static const Color textSecondaryColor = Color(0xFF607D8B);
  
  // Gradientes
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
  );
  
  static const LinearGradient itemGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
  );
  
  static const LinearGradient companyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
  );
  
  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
  );
  
  // Estilos de texto
  static const TextStyle headingStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    letterSpacing: 0.5,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );
  
  // Decoración de tarjetas
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(kBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class ItemDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const ItemDetailScreen({Key? key, required this.items}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getCompanyName(String db) {
    switch (db) {
      case 'IPX':
        return 'Impexpap';
      case 'ESP':
        return 'Esppapel';
      default:
        return db;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupItemsByCompany(
      List<Map<String, dynamic>> items) {
    return items.fold<Map<String, List<Map<String, dynamic>>>>(
      {},
      (map, item) {
        final db = item['db'] as String;
        if (!map.containsKey(db)) {
          map[db] = [];
        }
        map[db]!.add(item);
        return map;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.items.first;
    final groupedItems = _groupItemsByCompany(widget.items);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DetailTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar moderna con efecto parallax
            SliverAppBar(
              expandedHeight: size.height * 0.25,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: DetailTheme.primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                tooltip: 'Volver',
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Detalles del Artículo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fondo con gradiente
                    Container(
                      decoration: const BoxDecoration(
                        gradient: DetailTheme.headerGradient,
                      ),
                    ),
                    // Patrón decorativo
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          'https://www.transparenttextures.com/patterns/cubes.png',
                          repeat: ImageRepeat.repeat,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(); // Fallback si la imagen no carga
                          },
                        ),
                      ),
                    ),
                    // Efecto de partículas/puntos
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DotsPainter(),
                      ),
                    ),
                    // Icono decorativo
                    Positioned(
                      right: -50,
                      bottom: -20,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    // Efecto de viñeta en la parte inferior para mejorar la legibilidad del título
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Implementar compartir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compartir detalles'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  tooltip: 'Compartir',
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(kPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemHeader(firstItem),
                    const SizedBox(height: kItemSpacing),
                    ...groupedItems.entries.map((entry) =>
                        _buildCompanyInfo(context, entry.key, entry.value)),
                    const SizedBox(height: kItemSpacing),
                    _buildAvailabilityButton(context),
                    const SizedBox(height: kItemSpacing),
                    _buildCommonInfo(firstItem),
                    const SizedBox(height: kItemSpacing * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(Map<String, dynamic> item) {
    return Hero(
      tag: 'item-${item['codArticulo']}',
      child: Container(
        decoration: DetailTheme.cardDecoration.copyWith(
          gradient: DetailTheme.itemGradient,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Efecto táctil
              HapticFeedback.lightImpact();
            },
            splashColor: DetailTheme.primaryColor.withOpacity(0.1),
            highlightColor: DetailTheme.primaryColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado con código y badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DetailTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: DetailTheme.primaryColor.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_rounded,
                          color: DetailTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Código de Artículo',
                              style: TextStyle(
                                fontSize: 14,
                                color: DetailTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              '${item['codArticulo']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: DetailTheme.primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón para copiar el código
                      IconButton(
                        icon: const Icon(
                          Icons.copy_outlined,
                          color: DetailTheme.primaryColor,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: '${item['codArticulo']}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código copiado al portapapeles'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Copiar código',
                        splashRadius: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Descripción del artículo
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 14,
                      color: DetailTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    item['datoArt'] ?? 'Sin descripción',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: DetailTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context, String company, List<Map<String, dynamic>> companyItems) {
    final companyName = _getCompanyName(company);
    // Ordenar por lista de precios (de mayor a menor)
    companyItems.sort((a, b) => b['listaPrecio'].compareTo(a['listaPrecio']));
    final numberFormat = NumberFormat('#,##0.00');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: DetailTheme.cardDecoration.copyWith(
        gradient: DetailTheme.companyGradient,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Efecto táctil
            HapticFeedback.lightImpact();
          },
          splashColor: Colors.green.withOpacity(0.1),
          highlightColor: Colors.green.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con ícono de empresa
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade700.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const Spacer(),
                    // Indicador de cantidad de precios
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${companyItems.length} precios',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tabla de precios con estilo moderno
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Encabezado de tabla
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Lista de Precios',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: DetailTheme.textPrimaryColor,
                              ),
                            ),
                            Text(
                              'Precio',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: DetailTheme.textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                      // Filas de precios
                      ...companyItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: DetailTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${item['listaPrecio']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: DetailTheme.primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Lista de Precio',
                                      style: TextStyle(
                                        color: DetailTheme.textSecondaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${numberFormat.format(item['precio'])} ${item['moneda']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: DetailTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(
            context,
            '/item-detail-storage',
            arguments: {
              'companyItems': widget.items,
              'companyName': 'Todas las empresas',
            },
          );
        },
        icon: const Icon(Icons.inventory_2_outlined, size: 24),
        label: const Text('Ver Disponibilidad en Almacenes'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: DetailTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildCommonInfo(Map<String, dynamic> item) {
    return Container(
      decoration: DetailTheme.cardDecoration.copyWith(
        gradient: DetailTheme.infoGradient,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Efecto táctil
            HapticFeedback.lightImpact();
          },
          splashColor: DetailTheme.accentColor.withOpacity(0.1),
          highlightColor: DetailTheme.accentColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con ícono para la información adicional
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DetailTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: DetailTheme.accentColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: DetailTheme.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Información Adicional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DetailTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Información adicional en tarjetas
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoItem(
                        'Código de Familia', 
                        '${item['codigoFamilia']}', 
                        Icons.category_outlined
                      ),
                      // Aquí se pueden agregar más detalles si están disponibles
                      if (item['unidadMedida'] != null)
                        _buildInfoItem(
                          'Unidad de Medida', 
                          '${item['unidadMedida']}', 
                          Icons.straighten_outlined
                        ),
                      // Agregar más campos si están disponibles
                      if (item['peso'] != null)
                        _buildInfoItem(
                          'Peso', 
                          '${item['peso']} kg', 
                          Icons.scale_outlined
                        ),
                      if (item['fechaCreacion'] != null)
                        _buildInfoItem(
                          'Fecha de Creación', 
                          '${item['fechaCreacion']}', 
                          Icons.calendar_today_outlined
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DetailTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              size: 20,
              color: DetailTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: DetailTheme.textSecondaryColor,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: DetailTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para crear un efecto de puntos decorativos
class DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final dotSize = 2.0;
    final spacing = 20.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}