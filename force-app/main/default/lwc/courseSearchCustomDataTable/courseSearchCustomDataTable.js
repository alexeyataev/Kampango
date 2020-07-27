import LightningDatatable from 'lightning/datatable';
import courseNumberLinkTemplate from './courseNumberLinkTemplate.html';

import { COURSE_URL_FIELD } from 'c/globalConstansHelper';

export default class CourseSearchCustomDataTable extends LightningDatatable {
    static customTypes = {
        courseNumberTmp: {
            template: courseNumberLinkTemplate,
            standardCellLayout: true,
            typeAttributes:[ COURSE_URL_FIELD ]
        }
    };
}