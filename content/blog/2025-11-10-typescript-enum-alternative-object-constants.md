+++
title = "TypeScript Object Constants: A Flexible Enum Alternative"
slug = "typescript-enum-alternative-object-constants"
date = 2025-11-10

[extra]
author = "Tom Carrio"

[taxonomies]
tags = ["typescript", "swe"]
+++

Enums in TypeScript are very useful and have some utility behavior, but they are not without their limitations.

The primary one you may run into, especially if you are crossing package boundaries such as generated GraphQL types, internal type definitions, or stubbing test data; is that when an enum type is expected, only a direct reference to the enum can be utilized. This is true even if the values stored in that enum are identical.

### Showcase: Enum Limitations

Here is a quick showcase of this behavior for enums:

```typescript
enum EnumTypes {
  First = "FIRST",
  Second = "SECOND",
}

function withEnum(enumType: EnumTypes) {
  return enumType;
}

withEnum(EnumTypes.First);  // 🟩 You referenced the enum value via the enum reference. Type checker has PASSED.
withEnum("FIRST");          // 💥 You referenced the equivalent enum value via a string reference. Type checker has FAILED.
```

### The Object Constant Pattern

There is another common pattern that you might have seen as an alternative to TypeScript enums: Object constants.

If you are not familiar with `as const` syntax, this is called a **[const assertion](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions)**. A quick summary is that it makes a definition a literal, immutable value. That comes with convenient behavior in that TypeScript infers that type as exactly what is defined. In addition, just like an enum cannot be modified, an object constant cannot either.

This pattern is utilized more commonly now than ever; libraries like `graphql-codegen` output object constants instead of enums because of their flexibility.

### Showcase: Flexibility in Object Constants

An example extending on the above to showcase how these differ:

```typescript
const ConstTypes = {
  First: "FIRST",
  Second: "SECOND",
} as const;
type ConstType = (typeof ConstTypes)[keyof typeof ConstTypes];

function withConst(constType: ConstType) {
  return constType;
}

// TypeScript enum compatibility:
withEnum(EnumTypes.First);   // 🟩 You referenced the enum value via the enum reference. Type checker has PASSED.
withEnum("FIRST");           // 💥 You referenced the equivalent enum value via a string reference. Type checker has FAILED.
withEnum(ConstTypes.First);  // 💥 You referenced the equivalent enum value via the const reference. Type checker has FAILED.

// Object constant compatibilty:
withConst(EnumTypes.First);  // 🟩 You referenced the const value via the enum reference. Type checker has PASSED.
withConst("FIRST");          // 🟩 You referenced the equivalent via a string reference. Type checker has PASSED.
withConst(ConstTypes.First); // 🟩 You referenced the equivalent via the const reference. Type checker has PASSED.
```

The trick is in the additional `type ConstType` declaration, which equates to a union of all possible values in the object constant. In this case `"FIRST" | "SECOND"`. This still ensures correctness of value, but doesn't complain about not having used `ConstTypes.First` literally when you provide values that are technically correct. You can refer to `ConstType` for typing parameters and variables where you would have reached for `EnumTypes` before.

This makes the system much easier to integrate across package boundaries.

And in the end, they are still **100% type-safe**.

If you are shipping a consumable package, are generating code, or simply run into a scenario where you have an enum that is the cause of some headache because you are strictly required to reference the enum directly, consider refactoring to an object constant as a solution.
