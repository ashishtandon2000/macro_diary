import 'package:flutter/material.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/features/home_screen/view/widgets/food_list_tile.dart';
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
        actions: [
          IconButton(
            onPressed: () {
              model.revertLast();
            },
            icon: const Icon(Icons.undo),),
          IconButton(onPressed: ()async{
            final confirmed = await Util.wConfirmationDialog(context,title: "Confirm",msg: "Are you sure, you want to reset the summary?");

            Util.print.debug("#ONETIME ---- confirmed is $confirmed");

            if(confirmed==true){
              model.resetSummary();
            }
          }, icon: const Icon(Icons.refresh))
        ],
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
                _optionsRow(),
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
                            child: TabBarView(
                                children: [
                                  (model.foodServings.isEmpty)?
                                  Util.wNullScreenMessage("No food serving added yet.")
                                      :ListView.builder(
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
                                        Util.wBottomNotifyMsg(
                                          context: context,
                                          message: "Added ${serving.label}"
                                        );
                                      },
                                      editFun: () {
                                        _navigateToManageServing(
                                          foods: model.foodItems,
                                          id: serving.id,
                                          relativeFood: relativeFood
                                        );
                                      },
                                    );
                                  }),
                                  (model.foodItems.isEmpty)?
                                  Util.wNullScreenMessage("No food item added yet."):ListView.builder(
                                  itemCount: model.foodItems.length,
                                  itemBuilder: (context, index) {
                                    final foodItem = model.foodItems[index];
                                    return FoodListTile(
                                      foodItem: foodItem,
                                      addFun: () {
                                        model.updateUsingFoodItem(foodItem);
                                        Util.wBottomNotifyMsg(
                                            context: context,
                                            message: "Added ${foodItem.name}"
                                        );
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

  Widget _optionsRow() {
    final foods = context.read<HomeScreenViewmodel>().foodItems;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: (){
            _navigateToManageServing(foods: foods);
          },
          label: const Text("Serving"),
          icon: const Icon(Icons.add, size: 20),
        ),
        ElevatedButton.icon(
          onPressed: _navigateToManageFood,
          label: const Text("Food"),
          icon: const Icon(
            Icons.add,
            size: 20,
          ),
        ),
      ],
    );
  }

  _refreshScreen() {
    context.read<HomeScreenViewmodel>().loadContent();
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
      {String? id, FoodItem? relativeFood,required List<FoodItem> foods}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => ManageServingViewmodel(
            repo: ServingRepositoryImpl(),
          )..initialLoading(id, relativeFood, foods),
          child: ManageServing(),
        ),
      ),
    )
        .then((_) {
      _refreshScreen();
    });
  }
}
