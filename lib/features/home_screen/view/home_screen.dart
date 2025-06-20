import 'package:flutter/material.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/features/home_screen/view/widgets/food_list_tile.dart';
import 'package:macro_diary/features/home_screen/view/widgets/summary.dart';
import 'package:macro_diary/features/home_screen/view_model/home_screen_viewmodel.dart';
import 'package:macro_diary/features/manage_food_and_serving/view_models/manage_food_viewmodel.dart';
import 'package:macro_diary/features/manage_food_and_serving/views/manage_food.dart';
import 'package:macro_diary/features/manage_food_and_serving/views/manage_serving.dart';
import 'package:macro_diary/repositories/food_item_repository.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = context.read<HomeScreenViewmodel>();
      model.loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeScreenViewmodel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Macro Diary"),
      ),
      body: model.isLoading
          ? Util.wCircularLoader
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SummaryView(
                  sum: model.sum,
                ),
                const SizedBox(
                  height: 20,
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
                            child: TabBarView(children: [
                              ListView.builder(
                                  itemCount: model.foodServings.length,
                                  itemBuilder: (context, index) {
                                    final serving = model.foodServings[index];
                                    final relativeFood =
                                        model.getFoodById(serving.foodId);
                                    return FoodListTile(
                                      serving: serving,
                                      foodItem: relativeFood!,
                                      addFun: () {
                                        model.updateUsingFoodServing(serving);
                                      },
                                      editFun: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ManageServing(
                                                      servingId: serving.id,
                                                      relativeFood:
                                                          relativeFood,
                                                      foods: model.foodItems,
                                                    )));
                                      },
                                    );
                                  }),
                              ListView.builder(
                                  itemCount: model.foodItems.length,
                                  itemBuilder: (context, index) {
                                    final foodItem = model.foodItems[index];
                                    return FoodListTile(
                                      foodItem: foodItem,
                                      addFun: () {
                                        model.updateUsingFoodItem(foodItem);
                                      },
                                      editFun: () {
                                        _navigateToManageFood(foodItem.id);
                                      },
                                    );
                                  })
                            ]),
                          )
                        ],
                      )),
                )
              ],
            ),
    );
  }

  _navigateToManageFood(id) { // #TODO: make manage food stateless and call the inital loading right here
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ManageFoodViewmodel(
            repo: FoodRepositoryImpl(),
          ),
          // )..initialLoading(id),
          child: ManageFood(
            foodId: id,
          ),
        ),
      ),
    );
  }
}
