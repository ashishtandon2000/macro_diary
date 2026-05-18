import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/widgets/common_list_tile.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/dashboard/presentation/view/widgets/one_time_macros_input.dart';
import 'package:macro_diary/features/dashboard/presentation/view/widgets/summary_view.dart';
import 'package:macro_diary/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:macro_diary/features/food/presentation/view/manage_food_screen.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';
import 'package:macro_diary/features/foodServing/presentation/view/manage_serving_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // 0-serving, 1-summary, 2-food
  int _bottomBarIndex = 1;

  Future<void> _navigateToManageFood([String? foodId]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ManageFood(foodId: foodId)),
    );

    if (mounted) {
      await ref.read(dashboardProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToManageServing([String? servingId]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageServing(servingId: servingId),
      ),
    );

    if (mounted) {
      await ref.read(dashboardProvider.notifier).refresh();
    }
  }

  Future<void> _addButtonAction(DashboardState model) async {
    if (_bottomBarIndex == 0) {
      if (model.foods.isEmpty) {
        final confirm = await UIUtil.confirmationDialog(
          context,
          title: "Create Serving",
          msg:
              "You have not added any food item yet. To create serving please create a food item first.",
          yesText: "Add food",
        );

        if (confirm == true && mounted) {
          setState(() {
            _bottomBarIndex = 2;
          });
          await _navigateToManageFood();
        }
      } else {
        await _navigateToManageServing();
      }
    } else if (_bottomBarIndex == 2) {
      await _navigateToManageFood();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(dashboardProvider);
    final model = asyncState.value;
    final notif = ref.read(dashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Macro Diary"),
        actions: [
          if (model?.showRevertIcon == true)
            IconButton(
              onPressed: notif.revertLast,
              icon: const Icon(Icons.undo),
            ),
          IconButton(
            onPressed: model == null
                ? null
                : () async {
                    final confirmed = await UIUtil.confirmationDialog(
                      context,
                      title: "Confirm",
                      msg: "Are you sure, you want to reset the summary?",
                    );
                    if (confirmed == true) {
                      notif.resetSummary();
                    }
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: asyncState.when(
        data: _getBody,
        loading: () => UIUtil.circularLoader,
        error: (error, stackTrace) => UIUtil.nullScreenMsg("Error: $error"),
      ),
      bottomNavigationBar: _bottomBar(),
      floatingActionButton: _bottomBarIndex == 1
          ? null
          : FloatingActionButton(
              onPressed: model == null ? null : () => _addButtonAction(model),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _getBody(DashboardState model) {
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

  Widget _summaryBody(DashboardState model) {
    final notif = ref.read(dashboardProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SummaryView(summary: model.summary),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: OneTimeMacrosInput(
                        saveMacrosFunc: notif.updateUsingMacros,
                      ),
                    ),
                  );
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
                    Tab(child: Text("Saved Foods")),
                  ],
                ),
                Expanded(
                  child: _tabViews(model),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _servingsBody(DashboardState model) {
    if (model.servings.isEmpty) {
      return UIUtil.nullScreenMsg("No food serving added yet.");
    }

    return ListView.builder(
      itemCount: model.servings.length,
      itemBuilder: (context, index) {
        final serving = model.servings[index];
        if (!serving.hasAvailableFoods(model.foodMap)) {
          return const SizedBox.shrink();
        }

        return CommonListTile.serving(
          serving: serving,
          foodsById: model.foodMap,
          addFun: () => _addServingToSummary(context, serving),
          editFun: () => _navigateToManageServing(serving.id),
          deleteFun: () async {
            await ref
                .read(dashboardProvider.notifier)
                .deleteServing(serving.id);
          },
        );
      },
    );
  }

  Widget _foodsBody(DashboardState model) {
    if (model.foods.isEmpty) {
      return UIUtil.nullScreenMsg("No food item added yet.");
    }

    return ListView.builder(
      itemCount: model.foods.length,
      itemBuilder: (context, index) {
        final foodItem = model.foods[index];
        return CommonListTile.food(
          foodItem: foodItem,
          addFun: () {
            ref.read(dashboardProvider.notifier).updateUsingFood(foodItem);
            _showBottomMessage(context, "Added ${foodItem.name}");
          },
          editFun: () => _navigateToManageFood(foodItem.id),
          deleteFun: () async {
            await ref.read(dashboardProvider.notifier).deleteFood(foodItem.id);
          },
        );
      },
    );
  }

  BottomNavigationBar _bottomBar() {
    return BottomNavigationBar(
      currentIndex: _bottomBarIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dinner_dining_outlined),
          activeIcon: Icon(Icons.dinner_dining),
          label: "Servings",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.summarize_outlined),
          activeIcon: Icon(Icons.summarize),
          label: "Summary",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fastfood_outlined),
          activeIcon: Icon(Icons.fastfood),
          label: "Foods",
        ),
      ],
      onTap: (index) {
        setState(() {
          _bottomBarIndex = index;
        });
      },
    );
  }

  TabBarView _tabViews(DashboardState model) {
    return TabBarView(
      children: [
        _servingsBody(model),
        _foodsBody(model),
      ],
    );
  }

  void _addServingToSummary(BuildContext context, FoodServing serving) {
    final added =
        ref.read(dashboardProvider.notifier).updateUsingFoodServing(serving);
    _showBottomMessage(
      context,
      added ? "Added ${serving.label}" : "Food item not found for serving",
    );
  }

  void _showBottomMessage(BuildContext context, String message) {
    UIUtil.bottomNotifier(context: context, message: message);
  }
}
