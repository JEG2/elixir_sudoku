defmodule Sudoku do

  def to_board(raw_data) when is_list(raw_data) do
    raw_data
    |> Enum.map(fn " " -> nil; cell -> String.to_integer(cell) end)
    |> Enum.chunk(9)
  end
  def to_board(string) when is_binary(string) do
    Regex.scan(~r{[^\n]}, string)
    |> List.flatten
    |> to_board
  end

  def to_map(list) do
    list
    |> List.flatten
    |> Stream.with_index
    |> Enum.reduce(%{}, fn({ cell, cell_index }, acc) -> 
      row = div(cell_index,9)
      column = rem(cell_index,9)
      block = div(row,3) * 3 + div(column,3)
      Map.merge(acc, %{ [row, column, block] => cell } )
    end)
  end

  defp row_to_s(row) do
    row
    |> Enum.map(fn nil -> " "; cell -> cell end)
    |> List.insert_at(6,"|")
    |> List.insert_at(3,"|")
    |> Enum.join("")
  end

  def to_s(list) do
    list
    |> Map.values
    |> Enum.chunk(9)
    |> Enum.map(fn(row) -> row_to_s(row) end)
    |> Enum.join("\n")
  end

  def unsolved?(board) do
    board
    |> Map.values
    |> Enum.any?(fn(value) -> value == nil end)
  end

  def row(board, row) do
    fetch(board, fn [^row, _column, _block] -> true; _key -> false end)
  end

  def column(board, column) do
    fetch(board, fn [_row, ^column, _block] -> true; _key -> false end)
  end

  def block(board, row, column), do: block(board,div(row,3) * 3 + div(column,3) )
  def block(board, block) do
    fetch(board, fn [_row, _column, ^block] -> true; _key -> false end)
  end

  defp fetch(board, matcher) do
    board
    |> Map.keys
    |> Enum.filter(matcher)
    |> Enum.map(fn address -> Map.fetch!(board, address) end)
  end

  def blank_positions(board) do
    board
    |> Map.keys
    |> Enum.filter(fn( key ) -> board[key] == nil end)
  end

  def fill_cell(board) do
    p = possibilities(board, { :cell, fillable_cell(board) }) |> hd
    board
    |> Map.put(fillable_cell(board), p )
  end

  def fillable_cell(board) do
    board
    |> blank_positions
    |> Enum.find( fn([row, column, _]) ->
      possibilities(board, { :cell, row, column }) |> length == 1
    end)
  end

  def possibilities(list), do: [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ] -- list
  def possibilities(cell, { :cell, [row, column,_] } ) do
    cell |> possibilities({ :cell, row, column })
  end
  def possibilities(cell, { :cell, row, column }) do
    row(cell,row) ++ column(cell,column) ++ block(cell,row,column) |> possibilities
  end

end
