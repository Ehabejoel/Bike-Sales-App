import 'package:flutter/material.dart';
import '../models/bike.dart';
import '../utils/price_formatter.dart';
import '../services/bike_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final BikeService _bikeService = BikeService();
  TabController? _tabController;
  String _searchQuery = '';
  RangeValues _priceRange = RangeValues(0, 1000000);
  bool _isGridView = true;

  final List<String> categories = [
    'All',
    'Mountain',
    'Road',
    'Electric',
    'BMX'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Bike>>(
        stream: _bikeService.getBikes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final bikes = snapshot.data ?? [];
          final filteredBikes = bikes.where((bike) {
            final matchesSearch =
                bike.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    bike.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
            final matchesPrice = bike.price >= _priceRange.start &&
                bike.price <= _priceRange.end;
            final matchesCategory = _tabController?.index == 0 ||
                bike.category == categories[_tabController?.index ?? 0];
            return matchesSearch && matchesPrice && matchesCategory;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[700]!, Colors.blue[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  title: Text(
                    'Bike Market',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () => _showFilterBottomSheet(context),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search bikes...',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.blue[700],
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: Colors.blue[700],
                      tabs: categories
                          .map((category) => Tab(text: category))
                          .toList(),
                      onTap: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              filteredBikes.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text('No bikes found'),
                      ),
                    )
                  : _isGridView
                      ? _buildGridView(filteredBikes)
                      : _buildListView(filteredBikes),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<Bike> bikes) {
    return SliverPadding(
      padding: EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Adjusted for better proportions
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildBikeCard(bikes[index]),
          childCount: bikes.length,
        ),
      ),
    );
  }

  Widget _buildListView(List<Bike> bikes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildBikeListItem(bikes[index]),
        childCount: bikes.length,
      ),
    );
  }

  Widget _buildBikeCard(Bike bike) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias, // Add this for clean edges
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/bike-detail', arguments: bike),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6, // Increased image area
              child: Hero(
                tag: 'bike-${bike.id}',
                child: Image.network(
                  bike.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_bike,
                                size: 40, color: Colors.grey[400]),
                            SizedBox(height: 4),
                            Text(
                              'No image',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bike.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    formatCFA(bike.price),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          bike.sellerName[0],
                          style:
                              TextStyle(fontSize: 12, color: Colors.blue[900]),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bike.sellerName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
    );
  }

  Widget _buildBikeListItem(Bike bike) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/bike-detail', arguments: bike),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
              child: Hero(
                tag: 'bike-${bike.id}',
                child: Image.network(
                  bike.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 30),
                          Text('No image'),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 120,
                      height: 120,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bike.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      bike.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatCFA(bike.price),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          bike.sellerName,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text('Price Range'),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000000,
                divisions: 20,
                labels: RangeLabels(
                  formatCFA(_priceRange.start),
                  formatCFA(_priceRange.end),
                ),
                onChanged: (values) {
                  setState(() => _priceRange = values);
                  this.setState(() {});
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
