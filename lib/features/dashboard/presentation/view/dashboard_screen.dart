import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/widgets/common_list_tile.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/dashboard/presentation/view/widgets/one_time_macros_input.dart';
import 'package:macro_diary/features/dashboard/presentation/view/widgets/summary_view.dart';
import 'package:macro_diary/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:macro_diary/features/diary/domain/entities/diary_entry.dart';
import 'package:macro_diary/features/food/presentation/view/manage_food_screen.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';
import 'package:macro_diary/features/meal/presentation/view/manage_meal_screen.dart';
import 'package:macro_diary/features/settings/presentation/view/settings_screen.dart';
import 'package:macro_diary/features/user_data/presentation/view/personal_details_screen.dart';
import 'package:macro_diary/features/user_data/presentation/view/targets_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // 0-meal, 1-summary, 2-food
  int _bottomBarIndex = 1;
  bool _showSummaryDetails = false;

  Future<void> _navigateToManageFood([String? foodId]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ManageFood(foodId: foodId)),
    );

    if (mounted) {
      await ref.read(dashboardProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToManageMeal([String? mealId]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageMeal(mealId: mealId),
      ),
    );

    if (mounted) {
      await ref.read(dashboardProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    if (mounted) {
      await ref.read(dashboardProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToPersonalDetails() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PersonalDetailsScreen()),
    );

    if (mounted) {
      await ref.read(dashboardProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToTargets() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TargetsScreen()),
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
          title: "Create Meal",
          msg:
              "You have not added any food item yet. To create a meal, please create a food item first.",
          yesText: "Add food",
        );

        if (confirm == true && mounted) {
          setState(() {
            _bottomBarIndex = 2;
          });
          await _navigateToManageFood();
        }
      } else {
        await _navigateToManageMeal();
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
      drawer: _drawer(),
      appBar: AppBar(
        title: const Text("Macro Diary"),
        actions: [
          if (model?.showRevertIcon == true)
            IconButton(
              onPressed: () => notif.revertLast(),
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
                      await notif.resetSummary();
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

  Widget _drawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Text(
                "Macro Diary",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Personal Details"),
              onTap: () async {
                Navigator.of(context).pop();
                await _navigateToPersonalDetails();
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes_outlined),
              title: const Text("Targets"),
              onTap: () async {
                Navigator.of(context).pop();
                await _navigateToTargets();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Settings"),
              onTap: () async {
                Navigator.of(context).pop();
                await _navigateToSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody(DashboardState model) {
    switch (_bottomBarIndex) {
      case 0:
        return _mealsBody(model);
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
        _summaryActions(notif),
        if (_showSummaryDetails)
          Expanded(child: _summaryDetails(model))
        else
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(child: Text("Recent Meals")),
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

  Widget _summaryActions(DashboardNotifier notif) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showSummaryDetails = !_showSummaryDetails;
              });
            },
            icon: Icon(
              _showSummaryDetails ? Icons.keyboard_arrow_left : Icons.list_alt,
            ),
            label: Text(_showSummaryDetails ? "Back" : "View Details"),
          ),
          if (!_showSummaryDetails) ...[
            const SizedBox(width: 8),
            OutlinedButton.icon(
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
              icon: const Icon(Icons.add),
              label: const Text("Add Onetime"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryDetails(DashboardState model) {
    if (model.history.isEmpty) {
      return UIUtil.nullScreenMsg("No macros added yet.");
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: model.history.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = model.history[index];
        return ListTile(
          leading: Icon(_summaryEntryIcon(entry.type)),
          title: Text("${entry.typeLabel}: ${entry.title}"),
          subtitle: Text(_summaryEntrySubtitle(entry)),
          isThreeLine: entry.details.isNotEmpty,
          trailing: IconButton(
            tooltip: "Remove",
            onPressed: () async {
              await ref
                  .read(dashboardProvider.notifier)
                  .removeSummaryEntry(index);
              if (!context.mounted) return;
              _showBottomMessage(context, "Removed ${entry.title}");
            },
            icon: const Icon(Icons.delete_outline),
          ),
        );
      },
    );
  }

  Widget _mealsBody(DashboardState model) {
    if (model.meals.isEmpty) {
      return UIUtil.nullScreenMsg("No meal added yet.");
    }

    return ListView.builder(
      itemCount: model.meals.length,
      itemBuilder: (context, index) {
        final meal = model.meals[index];
        if (!meal.hasAvailableFoods(model.foodMap)) {
          return const SizedBox.shrink();
        }

        return CommonListTile.meal(
          meal: meal,
          foodsById: model.foodMap,
          addFun: () => _addMealToSummary(context, meal),
          editFun: () => _navigateToManageMeal(meal.id),
          deleteFun: () async {
            await ref.read(dashboardProvider.notifier).deleteMeal(meal.id);
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
          addFun: () async {
            await ref
                .read(dashboardProvider.notifier)
                .updateUsingFood(foodItem);
            if (!context.mounted) return;
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
          label: "Meals",
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
          if (_bottomBarIndex != 1) {
            _showSummaryDetails = false;
          }
        });
      },
    );
  }

  TabBarView _tabViews(DashboardState model) {
    return TabBarView(
      children: [
        _mealsBody(model),
        _foodsBody(model),
      ],
    );
  }

  Future<void> _addMealToSummary(BuildContext context, Meal meal) async {
    final added =
        await ref.read(dashboardProvider.notifier).updateUsingMeal(meal);
    if (!context.mounted) return;
    _showBottomMessage(
      context,
      added ? "Added ${meal.label}" : "Food item not found for this meal",
    );
  }

  void _showBottomMessage(BuildContext context, String message) {
    UIUtil.bottomNotifier(context: context, message: message);
  }

  IconData _summaryEntryIcon(DiaryEntryType type) {
    switch (type) {
      case DiaryEntryType.custom:
        return Icons.edit_note;
      case DiaryEntryType.food:
        return Icons.fastfood;
      case DiaryEntryType.meal:
        return Icons.dinner_dining;
    }
  }

  String _summaryEntrySubtitle(DiaryEntry entry) {
    final macros = entry.macros;
    final lines = [
      "Calories: ${macros.calories} | "
          "Protein: ${macros.protein} | "
          "Fats: ${macros.fats} | "
          "Carbs: ${macros.carbs}",
      if (entry.details.isNotEmpty) entry.details.join(", "),
    ];

    return lines.join("\n");
  }
}
