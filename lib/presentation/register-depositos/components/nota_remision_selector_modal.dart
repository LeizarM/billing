import 'package:flutter/material.dart';
import 'package:billing/domain/register-depositos/NotaRemision.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class NotaRemisionSelectorModal extends StatefulWidget {
  final List<NotaRemision> notas;
  final List<NotaRemision> selectedNotas;
  final Function(List<NotaRemision>) onSave;

  const NotaRemisionSelectorModal({
    Key? key, 
    required this.notas,
    required this.selectedNotas,
    required this.onSave,
  }) : super(key: key);

  @override
  NotaRemisionSelectorModalState createState() => NotaRemisionSelectorModalState();
}

class NotaRemisionSelectorModalState extends State<NotaRemisionSelectorModal> {
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

// Función para mostrar el modal
void showNotaRemisionSelector(
  BuildContext context,
  List<NotaRemision> notas,
  List<NotaRemision> selectedNotas,
  Function(List<NotaRemision>) onSave,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return NotaRemisionSelectorModal(
        notas: notas,
        selectedNotas: selectedNotas,
        onSave: onSave,
      );
    },
  );
}
