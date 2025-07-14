import 'package:flutter/material.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/features/home_screen/view/widgets/food_list_tile.dart';
import 'package:macro_diary/features/home_screen/view/widgets/onetime_macros.dart';
import 'package:macro_diary/features/home_screen/view/widgets/summary.dart';
import 'package:macro_diary/features/home_screen/view_model/home_screen_viewmodel.dart';
import 'package:macro_diary/features/manage_food_and_serving/view_models/manage_food_viewmodel.dart';
import 'package:macro_diary/features/manage_food_and_serving/view_models/manage_serving_viewmodel.dart';
import 'package:macro_diary/features/manage_food_and_serving/views/manage_food.dart';
import 'package:macro_diary/features/manage_food_and_serving/views/manage_serving.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/repositories/food_item_repository.dart';
import 'package:macro_diary/repositories/food_serving_repository.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // 0-serving, 1-summary, 2-food
  int _bottomBarIndex = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<HomeScreenViewmodel>();
      model.loadContent();
    });
  }

  _refreshScreen() {
    context.read<HomeScreenViewmodel>().loadContent();
  }

  _addButtonAction() {
    if (_bottomBarIndex == 0) {
      final items = context.read<HomeScreenViewmodel>().foodItems;
      _navigateToManageServing(foods: items);
    } else if(_bottomBarIndex == 2){
      _navigateToManageFood();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeScreenViewmodel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Macro Diary"),
        actions: [
          IconButton(
            onPressed: () {
              model.revertLast();
            },
            icon: const Icon(Icons.undo),
          ),
          IconButton(
              onPressed: () async {
                final confirmed = await Util.wConfirmationDialog(context,
                    title: "Confirm",
                    msg: "Are you sure, you want to reset the summary?");
                if (confirmed == true) {
                  model.resetSummary();
                }
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: model.isLoading ? Util.wCircularLoader : _getBody(model),
      bottomNavigationBar: _bottomBar(),
      floatingActionButton: (_bottomBarIndex == 1)
          ? null
          : FloatingActionButton(
              onPressed: _addButtonAction,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _getBody(HomeScreenViewmodel model) {
    switch (_bottomBarIndex) {
      case 0:
        return _servingsBody(model);
      case 1:
        return _summaryBody(model);
      case 2:
        return _foodsBody(model);
      default:
        return const Placeholder();
    }
  }

  Widget _summaryBody(HomeScreenViewmodel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SummaryView(
          sum: model.sum,
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
                            child: OneTimeMacrosInput(
                              saveMacrosFunc: model.updateUsingMacros,
                            ),
                          ));
                },
                child: const Text("Add Onetime Macros"),
              ),
            ],
          ),
        ),
        Expanded(
          child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(child: Text("Recent Servings")),
                      Tab(child: Text("Saved Foods"))
                    ],
                  ),
                  Expanded(
                    child: _tabViews(model),
                  )
                ],
              )),
        )
      ],
    );
  }

  Widget _servingsBody(HomeScreenViewmodel model) {
    if (model.foodServings.isEmpty) {
      return Util.wNullScreenMessage("No food serving added yet.");
    }
    return ListView.builder(
        itemCount: model.foodServings.length,
        itemBuilder: (context, index) {
          final serving = model.foodServings[index];
          final relativeFood = model.getFoodById(serving.foodId);
          return FoodListTile(
            serving: serving,
            foodItem: relativeFood!,
            addFun: () {
              model.updateUsingFoodServing(serving);
              Util.wBottomNotifyMsg(
                  context: context, message: "Added ${serving.label}");
            },
            editFun: () {
              _navigateToManageServing(
                  foods: model.foodItems,
                  id: serving.id,
                  relativeFood: relativeFood);
            },
            deleteFun: () {
              model.deleteServing(serving.id);
            },
          );
        });
  }

  Widget _foodsBody(HomeScreenViewmodel model) {
    if (model.foodItems.isEmpty) {
      return Util.wNullScreenMessage("No food item added yet.");
    }
    return ListView.builder(
        itemCount: model.foodItems.length,
        itemBuilder: (context, index) {
          final foodItem = model.foodItems[index];
          return FoodListTile(
            foodItem: foodItem,
            addFun: () {
              model.updateUsingFoodItem(foodItem);
              Util.wBottomNotifyMsg(
                  context: context, message: "Added ${foodItem.name}");
            },
            editFun: () {
              _navigateToManageFood(foodItem.id);
            },
            deleteFun: () {
              model.deleteFood(foodItem.id);
            },
          );
        });
  }

  BottomNavigationBar _bottomBar() {
    return BottomNavigationBar(
      currentIndex: _bottomBarIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dinner_dining_outlined),
          activeIcon: Icon(Icons.dinner_dining),
          label: "New Servings",
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.summarize_outlined),
            activeIcon: Icon(Icons.summarize),
            label: "Summary"),
        BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            activeIcon: Icon(Icons.fastfood),
            label: "New Food")
      ],
      onTap: (index) {
        Util.print.debug("Index is $index");
        setState(() {
          _bottomBarIndex = index;
        });
      },
    );
  }

  TabBarView _tabViews(HomeScreenViewmodel model) {
    return TabBarView(children: [
      (model.foodServings.isEmpty)
          ? Util.wNullScreenMessage("No food serving added yet.")
          : ListView.builder(
              itemCount: model.foodServings.length,
              itemBuilder: (context, index) {
                final serving = model.foodServings[index];
                final relativeFood = model.getFoodById(serving.foodId);
                return FoodListTile(
                  serving: serving,
                  foodItem: relativeFood!,
                  addFun: () {
                    model.updateUsingFoodServing(serving);
                    Util.wBottomNotifyMsg(
                        context: context, message: "Added ${serving.label}");
                  },
                  editFun: () {
                    _navigateToManageServing(
                        foods: model.foodItems,
                        id: serving.id,
                        relativeFood: relativeFood);
                  },
                  deleteFun: () {
                    model.deleteServing(serving.id);
                  },
                );
              }),
      (model.foodItems.isEmpty)
          ? Util.wNullScreenMessage("No food item added yet.")
          : ListView.builder(
              itemCount: model.foodItems.length,
              itemBuilder: (context, index) {
                final foodItem = model.foodItems[index];
                return FoodListTile(
                  foodItem: foodItem,
                  addFun: () {
                    model.updateUsingFoodItem(foodItem);
                    Util.wBottomNotifyMsg(
                        context: context, message: "Added ${foodItem.name}");
                  },
                  editFun: () {
                    _navigateToManageFood(foodItem.id);
                  },
                  deleteFun: () {
                    model.deleteFood(foodItem.id);
                  },
                );
              })
    ]);
  }

  _navigateToManageFood([String? id]) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ManageFoodViewmodel(
            repo: FoodRepositoryImpl(),
          )..initialLoading(id),
          child: ManageFood(),
        ),
      ),
    )
        .then((_) {
      _refreshScreen();
    });
  }

  _navigateToManageServing(
      {String? id, FoodItem? relativeFood, required List<FoodItem> foods}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ManageServingViewmodel(
          repo: ServingRepositoryImpl(),
        )..initialLoading(id, relativeFood, foods),
        child: ManageServing(),
      ),
    ))
        .then((_) {
      _refreshScreen();
    });
  }
}
