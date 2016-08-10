module student_m
    use log_file_m
    use persistent_object_m
    use sqlite

    implicit none
    private

    type, extends(persistent_object_t), public :: student_t
        private

        character(len=80) :: first_name_m = ''
        character(len=80) :: last_name_m = ''
        integer :: id_m
    contains
        procedure, public, pass(this) :: write_json, &
                                         write_xml, &
                                         load_data, &
                                         set_first_name, &
                                         set_last_name, &
                                         set_id, &
                                         delete_existing, &
                                         update_existing
    end type student_t

contains
    subroutine load_data(this, first, last, id)
        class(student_t), intent(inout) :: this
        character(len=*), intent(in) :: first
        character(len=*), intent(in) :: last
        integer, intent(in) :: id

        this%first_name_m = first
        this%last_name_m = last
        this%id_m = id
    end subroutine load_data

    subroutine set_first_name(this, first)
        class(student_t), intent(inout) :: this
        character(len=*), intent(in) :: first

        this%first_name_m = first
    end subroutine set_first_name

    subroutine set_last_name(this, last)
        class(student_t), intent(inout) :: this
        character(len=*), intent(in) :: last

        this%last_name_m = last
    end subroutine set_last_name

    subroutine set_id(this, id)
        class(student_t), intent(inout) :: this
        integer, intent(in) :: id

        this%id_m = id
    end subroutine set_id

    subroutine write_json(this, indent_level)
        class(student_t), intent(in) :: this
        integer, intent(in) :: indent_level

        character(len=(2*indent_level)) :: indent_string
        indent_string = repeat(' ', 2 * indent_level)

        print '(a,a)', indent_string, '{'
        print '(a,a,a,a)', indent_string, '  "first_name": "', &
              trim(this%first_name_m), '",'
        print '(a,a,a,a)', indent_string, '  "last_name": "', &
              trim(this%last_name_m), '",'
        print '(a,a,i5)', indent_string, '  "id": ', this%id_m
        print '(a,a)', indent_string, '}'
    end subroutine

    subroutine write_xml(this, indent_level)
        class(student_t), intent(in) :: this
        integer, intent(in) :: indent_level

        character(len=(4*indent_level)) :: indent_string
        indent_string = repeat(' ', 4 * indent_level)

        print '(a,a)', indent_string, '<student>'
        print '(a,a,a,a)', indent_string, '    <first_name>', &
            this%first_name_m, '</first_name>'
        print '(a,a,a,a)', indent_string, '    <last_name>', &
            this%last_name_m, '</last_name>'
        print '(a,a,a,a)', indent_string, '    <id>', this%id_m, '</id>'
        print '(a,a)', indent_string, '</student>'
    end subroutine write_xml

    subroutine delete_existing(this)
        class(student_t), intent(inout) :: this

        character(len=80) :: query

        write (query, '(a,i5,a)') 'delete from student where id=', &
            this%id_m, ';'

        call this%set_db_name('../cgi-data/students.db')
        call this%open_database()
        call sqlite3_do(this%db_m, query)
        call this%close_database()
    end subroutine delete_existing

    subroutine update_existing(this)
        class(student_t), intent(inout) :: this

        character(len=4096) :: query

        write (query, '(a,a,a,a,a,i5)') "update student set first_name='", &
            trim(this%first_name_m), &
            "', last_name='", &
            trim(this%last_name_m), &
            "' where id=", &
            this%id_m

        call log_append('/var/log/fabs.log', query)

        call this%set_db_name('../cgi-data/students.db')
        call this%open_database()
        call sqlite3_do(this%db_m, query)
        call this%close_database()
    end subroutine update_existing

end module student_m
