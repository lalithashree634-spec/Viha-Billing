import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biller/widgets/form_helpers.dart';

void main() {
  testWidgets('Verify 40px height for all AntD form components', (WidgetTester tester) async {
    final controller = TextEditingController(text: 'Sample text');
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ErpFormWidgets.textField(
                controller: controller,
                label: 'Category Name',
                hintText: 'e.g. Beverages',
              ),
              ErpFormWidgets.dropdownField<String>(
                label: 'Status',
                value: 'Active',
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                ],
                onChanged: (_) {},
              ),
              ErpFormWidgets.primaryButton(
                onPressed: () {},
                text: 'Save Category',
              ),
              ErpFormWidgets.outlinedButton(
                onPressed: () {},
                text: 'Cancel',
              ),
            ],
          ),
        ),
      ),
    );

    // Find the widgets
    final textFieldFinder = find.byType(TextField);
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    final primaryButtonFinder = find.byType(ElevatedButton);
    final outlinedButtonFinder = find.byType(OutlinedButton);

    final textfieldSize = tester.getSize(textFieldFinder);
    final dropdownSize = tester.getSize(dropdownFinder);
    final primaryBtnSize = tester.getSize(primaryButtonFinder);
    final outlinedBtnSize = tester.getSize(outlinedButtonFinder);

    print('RENDERED SIZES:');
    print('TextField: ${textfieldSize.width} x ${textfieldSize.height}');
    print('DropdownButtonFormField: ${dropdownSize.width} x ${dropdownSize.height}');
    print('PrimaryButton: ${primaryBtnSize.width} x ${primaryBtnSize.height}');
    print('OutlinedButton: ${outlinedBtnSize.width} x ${outlinedBtnSize.height}');

    // Also check the InputDecorator border inside TextField!
    final inputDecoratorFinder = find.descendant(
      of: textFieldFinder,
      matching: find.byType(InputDecorator),
    );
    final decoratorSize = tester.getSize(inputDecoratorFinder);
    print('InputDecorator inside TextField: ${decoratorSize.width} x ${decoratorSize.height}');

    expect(textfieldSize.height, 40.0);
    expect(dropdownSize.height, 40.0);
    expect(primaryBtnSize.height, 40.0);
    expect(outlinedBtnSize.height, 40.0);
    expect(decoratorSize.height, 40.0);
  });
}
