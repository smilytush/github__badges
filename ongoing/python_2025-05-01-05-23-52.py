def filter_list(items, condition):
    return [item for item in items if condition(item)]

