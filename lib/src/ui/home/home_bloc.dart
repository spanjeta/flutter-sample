/*
 * @copyright : ToXSL Technologies Pvt. Ltd. < www.toxsl.com >
 * @author     : Shiv Charan Panjeta < shiv@toxsl.com >
 * All Rights Reserved.
 * Proprietary and confidential :  All information contained herein is, and remains
 * the property of ToXSL Technologies Pvt. Ltd. and its partners.
 * Unauthorized copying of this file, via any medium is strictly prohibited.
 */

import 'package:bloc/bloc.dart';

import 'package:news_app/src/api/api_repository.dart';
import 'package:news_app/src/model/topheadlinesnews/headline_response.dart';

abstract class DataState {}

class DataInitial extends DataState {}

class DataLoading extends DataState {}

class DataSuccess extends DataState {
  final ResponseTopHeadlinesNews data;

  DataSuccess(this.data);
}

class DataFailed extends DataState {
  final String errorMessage;

  DataFailed(this.errorMessage);
}

class DataEvent {
  final String category;
  DataEvent(this.category);
}

class HomeBloc extends Bloc<DataEvent, DataState> {
  @override
  DataState get initialState => DataInitial();

  @override
  Stream<DataState> mapEventToState(DataEvent event) async* {
    yield DataLoading();
    final apiRepository = ApiRepository();
    final categoryLowerCase = event.category.toLowerCase();
    String selectedCategory = "";
    switch (categoryLowerCase) {
      case 'all':
        selectedCategory = "";
        break;
      case 'business':
        selectedCategory = "business";
        break;
      case 'entertainment':
        selectedCategory = "entertainment";

        break;
      case 'health':
        selectedCategory = "health";

        break;
      case 'science':
        selectedCategory = "science";
        break;
      case 'sport':
        selectedCategory = "sport";
        break;
      case 'technology':
        selectedCategory = "technology";
        break;
      default:
        yield DataFailed('Unknown category');
    }

    final data = await apiRepository.fetchNews(selectedCategory);
    if (data.error == null) {
      yield DataSuccess(data);
    } else {
      yield DataFailed('');
    }
  }
}
