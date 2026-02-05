import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;

  const DashboardPage({super.key, required this.user, required this.onLogout});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();

  List<Product> _products = [];
  List<Order> _orders = [];
  bool _loadingProducts = false;
  bool _loadingOrders = false;
  String _searchQuery = '';
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
    });

    try {
      final products = _searchQuery.isEmpty
          ? await _apiService.getProducts()
          : await _apiService.searchProducts(_searchQuery);
      setState(() {
        _products = products;
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _loadingProducts = false;
      });
      _showMessage('Failed to load products: ${e.toString()}', true);
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loadingOrders = true;
    });

    try {
      final orders = await _apiService.getOrders(widget.user.id);
      setState(() {
        _orders = orders;
        _loadingOrders = false;
      });
    } catch (e) {
      setState(() {
        _loadingOrders = false;
      });
      _showMessage('Failed to load orders: ${e.toString()}', true);
    }
  }

  void _showMessage(String msg, bool isError) {
    setState(() {
      _message = msg;
      _isError = isError;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }

  Future<void> _placeOrder(Product product) async {
    final quantityController = TextEditingController(text: '1');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${product.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available: ${product.availableQuantity}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final quantity = int.tryParse(quantityController.text) ?? 0;
      if (quantity <= 0) {
        _showMessage('Invalid quantity', true);
        return;
      }

      try {
        await _apiService.createOrder(widget.user.id, product.id, quantity);
        _showMessage('Order placed successfully!', false);
        _loadProducts();
        _loadOrders();
      } catch (e) {
        _showMessage(e.toString().replaceAll('Exception: ', ''), true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag), text: 'Products'),
            Tab(icon: Icon(Icons.history), text: 'Order History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                _loadProducts();
              } else {
                _loadOrders();
              }
            },
          ),
          PopupMenuButton<dynamic>(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.user.email,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: widget.onLogout,
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_message != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _isError ? Colors.red.shade50 : Colors.green.shade50,
              child: Text(
                _message!,
                style: TextStyle(
                  color: _isError ? Colors.red.shade900 : Colors.green.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildOrdersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                        _loadProducts();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (value) {
              _loadProducts();
            },
          ),
        ),
        Expanded(
          child: _loadingProducts
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child:
                                    Text(product.productName[0].toUpperCase()),
                              ),
                              title: Text(product.productName),
                              subtitle: Text(
                                'Available: ${product.availableQuantity}',
                                style: TextStyle(
                                  color: product.availableQuantity > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: product.availableQuantity > 0
                                    ? () => _placeOrder(product)
                                    : null,
                                icon: const Icon(Icons.shopping_cart, size: 16),
                                label: const Text('Order'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return _loadingOrders
        ? const Center(child: CircularProgressIndicator())
        : _orders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadOrders,
                child: ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${order.quantity}'),
                        ),
                        title: Text(order.productName ?? 'Product'),
                        subtitle: Text(
                          '${_formatDate(order.timestamp)} • Qty: ${order.quantity}',
                        ),
                        trailing: Icon(
                          Icons.check_circle,
                          color: Colors.green.shade400,
                        ),
                      ),
                    );
                  },
                ),
              );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
