String percentEncode(String input) {
  // Do initial percentage encoding of using Uri.encodeComponent()
  input = Uri.encodeComponent(input);

  // Percentage encode characters ignored by Uri.encodeComponent()
  input = input.replaceAll('-', '%2D');
  input = input.replaceAll('_', '%5F');
  input = input.replaceAll('.', '%2E');
  input = input.replaceAll('!', '%21');
  input = input.replaceAll('~', '%7E');
  input = input.replaceAll('*', '%2A');
  input = input.replaceAll('\'', '%5C');
  input = input.replaceAll('(', '%28');
  input = input.replaceAll(')', '%29');

  return input;
}
