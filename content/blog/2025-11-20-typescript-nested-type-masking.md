+++
title = "TypeScript Nested Type Selection"
slug = "typescript-nested-type-selection"
# date = 2025-11-20
draft = true

[extra]
author = "Tom Carrio"

[taxonomies]
tags = ["typescript", "swe"]
+++

In TypeScript, you often need to take subsets of types. There are several utility types that can help you achieve this, such as `Pick`, `Omit`, and `Partial`.

However, these utility types at scale can feel pretty clunky and can lead to verbose code. To address this, I worked on a feature called **nested type masking**.

If you have ever worked with GraphQL, you might recognize the pattern of nested type masking. This pattern allows you to create a new type that is a subset of an existing type, while also allowing you to specify the properties that you want to include explicitly.

In large, the need for this utility type arose from the code generation capabilities of GraphQL tools. These tools often generate types that are nested within other types, and it can be difficult to extract the necessary information from these deeply nested types.

To that end, I showcase here the `PickMask` utility type.

## Example

Let's start with the origin type definition. This will be a type that has various nested properties which we want to pick out from the type.

TODO: Define a type with multiple nested properties, showcasing how the selection of properties works.

## The Magic Type

```typescript
type Primitive = string | number | boolean | null | undefined;
type IndexableObject = Record<string, unknown>;
type AnyArray = Array<unknown>;
type ArrayType<T> = T extends Array<infer U> ? U : never;
type Sentinel = undefined;

type SelectionOfObject<Source extends IndexableObject> = Partial<{
    [K in keyof Source]: SelectionOfUnknown<Source[K]>;
}>;

type SelectionOfArray<Source extends AnyArray> = Partial<{
    [K in keyof ArrayType<Source>]: SelectionOfUnknown<ArrayType<Source>[K]>;
}>;

type SelectionOfUnknown<Source> = Source extends AnyArray
    ? SelectionOfArray<Source>
    : Source extends IndexableObject
      ? SelectionOfObject<Source>
      : Sentinel;

export type Select<Source extends IndexableObject | AnyArray, Selection extends SelectionOfUnknown<Source>> = {
    [K in keyof Selection & keyof Source]: Selection[K] extends Sentinel
        ? Source[K]
        : Source[K] extends AnyArray
          ? ArrayType<Source[K]> extends IndexableObject
              ? Selection[K] extends SelectionOfUnknown<ArrayType<Source[K]>>
                  ? ArrayType<Source[K]> extends IndexableObject
                      ? Array<Select<ArrayType<Source[K]>, Selection[K]>>
                      : ArrayType<Source[K]> extends Primitive
                        ? Array<SelectionOfUnknown<ArrayType<Source[K]>>>
                        : never
                  : never
              : never
          : Source extends IndexableObject
            ? Selection[K] extends SelectionOfUnknown<Source[K]>
                ? Source[K] extends IndexableObject
                    ? Select<Source[K], Selection[K]>
                    : Source[K] extends Primitive
                      ? SelectionOfUnknown<Source[K]>
                      : never
                : never
            : never;
};
```
