/*******************
=========================================
CPRG-307 Assignment 3
Authors:
   - Minh Tam Nguyen
   - Mikael Ly
   - Xiaomei He
   - Elliot Jost

This is the solution file for Assignment 3 of Databases. 
=========================================
=========================================
Part 1 Requirements
=========================================
- Use explicit cursors to read from NEW_TRANSACTIONS

- Insert the read tables into TRANSACTION_DETAIL and TRANSACTION_HISTORY

- Update the appropriate account balance in ACCOUNT
   - Determine Debit(D) or Credit(C) to decide whether to add or subtract.
   
- Removed processed transactions from NEW_TRANSACTIONS

- Include COMMIT to save changes
=========================================
Part 2 Requirements
=========================================
- Handle good + bad transactions

- Exception handling for both anticipated and unanticipated errors

- Error logging
   - Write descriptive error messages and transaction info into the WKIS_ERROR_LOG table

- Bad Transactions
   -   Remain in NEW_TRANSACTIONS (don't delete)
   - Should not update ACCOUNT, TRANSACTION_DETAIL, or TRANSACTION_HISTORY

- Valid Transactions
   - Remove processed transactions from NEW_TRANSACTIONS (same as part 1)

- Error Handling Rules
   - Only first error per transaction logged
   - Do not exit main loop on error, continue processing other transactions

- Only allowed hard coding 'C' and 'D' values as Constants

=========================================
Part 2 Errors to handle
=========================================
- Missing Transaction Number (NULL transaction number)
- Debits and Credits Not Equal (transaction imbalance)
- Invalid Account Number (account not found)
- Negative Transaction Amount
- Invalid Transaction Type (anything other than C or D)
- Unanticipated Errors


*******************/

   SET SERVEROUTPUT ON;

declare begin
   -- Outer loop: select distinct transaction numbers to process one transaction at a time
   for txn_id_rec in (
      select distinct transaction_no
        from new_transactions
   ) loop
      begin
         -- Check if transaction number is NULL, raise error if yes
         if txn_id_rec.transaction_no is null then
            raise_application_error(
               -20001,
               'Missing transaction number'
            );
         end if;

         -- Inner loop: process all rows for the current transaction
         for txn_row_rec in (
            select transaction_no,
                   transaction_date,
                   description,
                   account_no,
                   transaction_type,
                   transaction_amount
              from new_transactions
             where transaction_no = txn_id_rec.transaction_no
         ) loop
            dbms_output.put_line('Processing: transaction id: '
                                 || txn_row_rec.transaction_no
                                 || ' amount: '
                                 || txn_row_rec.transaction_amount
                                 || ' type: ' || txn_row_rec.transaction_type);
         end loop;

      exception
         when others then
            dbms_output.put_line('Error: ' || sqlerrm);
            -- Insert error message into error log table
            insert into wkis_error_log ( error_msg ) values ( sqlerrm );
      end;
   end loop;
end;
/