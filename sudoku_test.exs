Code.load_file("sudoku.exs", __DIR__)

ExUnit.start
ExUnit.configure exclude: :pending, trqce: true

defmodule SudokuTemplate do
  use ExUnit.CaseTemplate

  setup do
    base_string = "9 4 7   2\n  239 654\n   6  971\n    37549\n5972 6 8 \n 41      \n   8132 5\n1854 23  \n 36 594 8"
    zero  = [ 9,   nil, 4,   nil, 7,   nil, nil, nil, 2   ]
    one   = [ nil, nil, 2,   3,   9,   nil, 6,   5,   4   ]
    two   = [ nil, nil, nil, 6,   nil, nil, 9,   7,   1   ]
    three = [ nil, nil, nil, nil, 3,   7,   5,   4,   9   ]
    four  = [   5,   9,   7,   2, nil, 6,   nil, 8,   nil ]
    five  = [ nil,   4,   1, nil, nil, nil, nil, nil, nil ]
    six   = [ nil, nil, nil,   8,   1,   3,   2, nil,   5 ]
    seven = [   1,   8,   5,   4, nil,   2,   3, nil, nil ]
    eight = [ nil,   3,   6, nil,   5,   9,   4, nil,   8 ]
    eight_after_insert = [ nil,   3,   6, 7,   5,   9,   4, nil,   8 ]
    base  = [zero, one, two, three, four, five, six, seven, eight]
    base_after_insert  = [zero, one, two, three, four, five, six, seven, eight_after_insert]
    { :ok, base: base,
      base_after_insert: base_after_insert,
      base_string: base_string }
  end
end

defmodule SudokuTest do
  use ExUnit.Case
  use SudokuTemplate, async: true

  test "get row 0 from base sudoku board", %{base: base} do
    row =
      base
      |> Sudoku.to_map
      |> Sudoku.row(0)
      |> Enum.sort
    assert row == Enum.fetch(base,0) |> elem(1) |> Enum.sort
  end

  test "get column 0 from base sudoku board", %{base: base} do
    actual =
      base
      |> Sudoku.to_map
      |> Sudoku.column(0)
      |> Enum.sort
    expected = [ 9, nil, nil, nil, 5, nil, nil, 1, nil ] |> Enum.sort
    assert actual == expected
  end

  test "get block 2 (0 indexed, reading left to right)", %{base: base} do 
    actual =
      base
      |> Sudoku.to_map
      |> Sudoku.block(2)
      |> Enum.sort
    expected = Enum.sort([ nil, nil, 2, 6, 5, 4, 9, 7, 1 ])
    assert actual == expected
  end

  test "get block that contains cell 0,6", %{base: base} do
    block = [ nil, nil, 2, 6, 5, 4, 9, 7, 1 ] |> Enum.sort
    assert Sudoku.block(Sudoku.to_map(base),0,6)|>Enum.sort == block
  end

  test "can fill a cell with only one variable to fill", %{base: base, base_after_insert: base_after_insert} do
    assert Sudoku.fill_cell(Sudoku.to_map(base)) == base_after_insert |> Sudoku.to_map
  end

  test "can identify an unsolved puzzle", %{base: base} do
    assert Sudoku.unsolved?(Sudoku.to_map(base)) == true
  end

  test "turns the board into a map", %{base: base} do
    assert Sudoku.to_map(base)[[0,0,0]] == 9
    assert Sudoku.to_map(base)[[7,0,6]] == 1
  end

  test "can find a cell with only one variable to fill", %{base: base} do
    assert Sudoku.fillable_cell(Sudoku.to_map(base)) == [ 8,3,7 ]
  end

  test "find blank positions" do
    zero  = [[ 9,   nil, 4,   nil, 7,   nil, nil, nil, 2   ]]
    assert Sudoku.blank_positions(Sudoku.to_map(zero)) == [ [0,1,0], [0,3,1], [0,5,1], [0,6,2], [0,7,2] ]
  end

  test "correctly return no blank positions" do
    zero  = [[ 9, 4, 7, 2 ]]
    assert Sudoku.blank_positions(Sudoku.to_map(zero)) == []
  end

  test "returns missing numbers row/column/block", state do
    assert Sudoku.possibilities(Sudoku.to_map(state[:base]), {:cell, 0, 6 })  == [8]
  end

  test "can read a string into a sudoku map", %{base: base, base_string: base_string } do
    assert Sudoku.to_board(base_string)  == base
  end


end
