import 'package:flutter/material.dart';
import '../models/bike.dart';
import '../utils/price_formatter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController; // Make nullable
  final List<Bike> bikes = [
    Bike(
      id: '1',
      title: 'Mountain Bike Pro',
      description: 'Professional mountain bike with front suspension',
      price: 299999,
      imageUrl: 'assets/images/bike1.jpg',
      seller: 'John Doe',
      category: 'Mountain',
    ),
    Bike(
      id: '2',
      title: 'Electric City Bike',
      description: 'Urban electric bike with 50km range',
      price: 799999,
      imageUrl: 'assets/images/bike2.jpg',
      seller: 'Sarah Smith',
      category: 'Electric',
    ),
    Bike(
      id: '3',
      title: 'BMX Stunt Bike',
      description: 'Perfect for tricks and stunts',
      price: 149999,
      imageUrl: 'assets/images/bike3.jpg',
      seller: 'Mike Johnson',
      category: 'BMX',
    ),
    Bike(
      id: '4',
      title: 'Road Racer X1',
      description: 'Lightweight carbon frame road bike',
      price: 899999,
      imageUrl: 'assets/images/bike4.jpg',
      seller: 'Emma Wilson',
      category: 'Road',
    ),
    Bike(
      id: '5',
      title: 'Electric Mountain Bike',
      description: 'Powerful electric mountain bike with dual suspension',
      price: 1299999,
      imageUrl: 'assets/images/bike5.jpg',
      seller: 'David Brown',
      category: 'Electric',
    ),
    Bike(
      id: '6',
      title: 'BMX Freestyle',
      description: 'Durable BMX bike for park and street',
      price: 199999,
      imageUrl: 'assets/images/bike6.jpg',
      seller: 'Tom Davis',
      category: 'BMX',
    ),
    Bike(
      id: '7',
      title: 'Road Elite',
      description: 'Professional racing road bike',
      price: 1499999,
      imageUrl: 'assets/images/bike7.jpg',
      seller: 'Lisa Anderson',
      category: 'Road',
    ),
    Bike(
      id: '8',
      title: 'Mountain Explorer',
      description: 'All-terrain mountain bike with premium components',
      price: 449999,
      imageUrl: 'assets/images/bike8.jpg',
      seller: 'Chris Martin',
      category: 'Mountain',
    ),
  ];

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
    _tabController?.dispose(); // Safely dispose
    super.dispose();
  }

  List<Bike> get filteredBikes {
    return bikes.where((bike) {
      final matchesSearch = bike.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          bike.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPrice =
          bike.price >= _priceRange.start && bike.price <= _priceRange.end;
      final matchesCategory = _tabController?.index == 0 ||
          bike.category == categories[_tabController?.index ?? 0];
      return matchesSearch && matchesPrice && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
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
                    onChanged: (value) => setState(() => _searchQuery = value),
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
          _isGridView ? _buildGridView() : _buildListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildGridView() {
    return SliverPadding(
      padding: EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9, // Increased to make cards shorter
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildBikeCard(filteredBikes[index]),
          childCount: filteredBikes.length,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildBikeListItem(filteredBikes[index]),
        childCount: filteredBikes.length,
      ),
    );
  }

  Widget _buildBikeCard(Bike bike) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/bike-detail', arguments: bike),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4, // Increased image area
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Hero(
                  tag: 'bike-${bike.id}',
                  child: Image.asset(
                    bike.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.directions_bike, size: 50),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 4), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bike.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13, // Slightly reduced font size
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2), // Reduced spacing
                  Text(
                    formatCFA(bike.price),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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
                child: Image.asset(
                  // Changed from Image.network to Image.asset
                  bike.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error, size: 30),
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
                          bike.seller,
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
                child: Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
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
